# Test-strategi

Autoritativ reference for testniveauer, dækningskrav og mocking-principper på tværs
af projekter og teknologi-stacks. Se også `testing-and-docs.md` for den konkrete
AI-vendte commit-tjekliste.

## De fire testniveauer

### Unit tests

**Formål:** Verificér isoleret logik — rene funktioner, datamodeller, tilstandsmaskiner.

**Hvad hører hjemme her:**
- Forretningslogik uden I/O
- Parsing og validering af input
- Tilstandsmaskiner og state-transitions
- Fejlhåndtering i isolerede komponenter

**Hvad hører ikke hjemme her:**
- Alt der kræver en database, fil eller netværk — brug integration tests i stedet.

**Navngivning:** Test-funktionens navn beskriver scenariet, ikke implementeringen.
`test_empty_username_is_rejected` er bedre end `test_validate_user_error`.

Eksempler pr. stack:
- Rust: `#[test]` i samme fil som koden eller i `tests/`-mappen
- Python: `pytest`, en testfil pr. modul
- Go: `_test.go`-filer, `TestXxx`-funktioner

### Integration tests

**Formål:** Verificér at komponenter fungerer korrekt sammen — mod rigtig database,
rigtig filesystem, rigtige interne services.

**Grundregel: Brug aldrig mocks til database- eller I/O-logik.** Mocks har gentagne
gange maskeret fejl der kun dukkede op i produktion (se `testing-and-docs.md`).

**Hvad hører hjemme her:**
- Alle SQL-queries og database-interaktioner
- Filsystem-operationer
- Interne service-kald
- Autentifikationsflows (token-udstedelse og -validering)

**Opsætning:**
- Hvert miljø (test, staging, prod) bruger sin egen database — aldrig delt.
- Integrationstests opretter og rydder op i testdata i samme test (se `testing-and-docs.md`).
- In-memory database (f.eks. `sqlite::memory:`, H2) er tilladt til hurtige tests,
  men supplement ikke erstatning for tests mod den rigtige database.

Eksempler pr. stack:
- Rust/SQLx: `#[sqlx::test]` — automatisk migration og rollback per test
- Python: `pytest` med fixture der spinner testdatabase op
- Go: `testcontainers-go` eller lokal database med `TestMain`-setup

### End-to-end tests (e2e)

**Formål:** Verificér komplette brugerflows fra frontend til backend, som en rigtig
bruger ville opleve dem.

**Hvornår kræves e2e:**
- Web-applikationer med UI: altid for kritiske flows (login, kernefunktionalitet, sletning)
- API-projekter: e2e kan erstattes af omfattende integrationstests mod rigtig database
- CLI-værktøjer: subprocess-tests der kører det kompilerede program end-to-end

**Scope:** Dæk kritiske flows, ikke alle UI-tilstande. E2e-tests er dyre at vedligeholde.

**Oprydning:** E2e-tests rydder altid op via applikationens egne API-endpoints
(`DELETE /auth/me`, `DELETE /rooms/:id`) — aldrig direkte i databasen.

Anbefalede værktøjer:
- Web-UI: Playwright (foretrukket), Cypress
- API-only: `cargo test` + `reqwest`, `pytest` + `httpx`

### Sikkerhedstests (OWASP)

**Hvornår kræves det:** Alle web-applikationer der eksponeres offentligt eller
håndterer brugerdata.

**Minimumskrav for web-applikationer:**

| Test | Hvornår | Værktøj |
|------|---------|---------|
| OWASP Top 10 gennemgang | Før første deploy og ved større ændringer | Manuel + checkliste |
| Afhængighedssårbarhed-scanning | Hvert CI-kørsel | `cargo audit`, `pip-audit`, `npm audit` |
| OWASP ZAP baseline scan | Staging efter hvert deploy | OWASP ZAP (Docker) |
| Autentificerings- og autorisationstest | Ved al auth-relateret kode | Manuel + integration tests |
| Input-valideringstest | Ved ny brugerinput | Integration tests + ZAP |

**Konkrete krav til tests:**
- Afvisning af ugyldige tokens skal have en integrationstest (forventet: 401/403)
- SQL-injection-forsøg skal have en integrationstest (parametriserede queries)
- Log-sanitering: test at følsomme værdier (tokens, passwords) ikke fremgår af logs
- Rate limiting: test at gentagende fejlede logins afvises

Tjeklisten i `security.md` beskriver de konkrete OWASP-krav pr. kategori.

---

## Dækningskrav

Dækning er en nødvendig, men ikke tilstrækkelig, kvalitetsindikator.
100 % dækning med kun happy-path-tests er meningsløs.

**Minimumskrav:**

| Komponent | Dækning | Bemærkning |
|-----------|---------|------------|
| Forretningslogik (unit) | 80 % linjdækning | Inkl. fejlstier |
| Database-lag (integration) | Alle SQL-queries dækket | Mindst én `#[sqlx::test]` pr. query |
| Auth-flows | 100 % for afvisnings-stier | 401, 403, udløbet token |
| Kritiske brugerflows | E2e-test for hvert flow | Login, kernefeature, sletning |
| Sikkerhedskritisk kode | 100 % inkl. fejlstier | Password-hashing, token-validering |

**Hvad dækning ikke måler:** Korrekthed af selve forventningerne. En test der
`assert!(result.is_ok())` uden at tjekke indholdet tæller som dækning men fanger intet.

---

## Mocking-principper

**Grundregel: Mock så lidt som muligt. Mock aldrig det du faktisk vil teste.**

### Hvad må mockes

- Eksterne tredjepartstjenester (betalingsgateway, SMS-udbyder, ekstern OAuth-udbyder)
- Hardware-afhængigheder (kamera, GPS, seriel port)
- Systemtid og tilfældig talgeneration i unit tests
- Netværkskald i unit tests (ikke i integrationstests)

### Hvad må ikke mockes

- Projektets egen database (brug `#[sqlx::test]`, `sqlite::memory:`, eller testcontainers)
- Projektets egne interne services (brug rigtig opsætning i integrationstests)
- Filsystem i integrationstests (brug en temp-mappe)
- Autentificeringslogik i integrationstests (test den rigtige implementering)

### Mock-grænse: ved systemgrænsen, ikke indefra

Mocks hører hjemme ved grænsen til *andre* systemer, ikke som en genvej til at undgå
opsætning. Hvis opsætningen er besværlig, er det et signal om at arkitekturen kan
forbedres (se ADR-0004: lib+bin-split for testbarhed).

---

## Deterministiske tests

En test der sommetider fejler er værre end ingen test — den skaber støj og tillid
til at CI er grønt når det ikke er.

Krav:
- Ingen afhængighed af systemtid uden at mocke/injicere den
- Ingen afhængighed af rækkefølge mellem tests
- Ingen delte mutable tilstande mellem tests (global state, delte databaser)
- Tilfældig talgeneration mockes eller seedes deterministisk i unit tests

---

## CI-integration

Alle testniveauer skal køre i CI. Se `ci-cd.md` (endnu ikke skrevet) for den
fulde pipeline-definition.

Minimum:
```
unit tests       → altid, blokerende
integration      → altid, blokerende
e2e              → ved deploy til staging, blokerende
cargo audit      → altid, blokerende
OWASP ZAP        → ved deploy til staging, blokerende
```

En grøn CI-pipeline med `cargo audit` der finder kritiske sårbarheder skal
behandles som et mislykket build.

---

## Post-deploy smoke test

Kør en minimal smoke test mod produktion efter hvert deploy. Tester ikke
forretningslogik — kun at kritiske endpoints svarer korrekt og med forventet
statuskode. Fejl i smoke testen skal stoppe deployet og trigge rollback.

Inkludér mindst:
- Health-endpoint: `GET /health` → 200
- Autentificeret endpoint med gyldigt token → 200
- Autentificeret endpoint med ugyldigt token → 401

# Code review — PR-proces og definition of done

Standard for hvad der tjekkes i et code review, hvornår en PR er klar,
og hvad der er definition of done. Gælder for både menneskelige og
AI-genererede PRs.

## PR-størrelse og scope

**Én PR — én ting.** En PR der retter en bug, tilføjer en feature *og*
refaktorerer noget uafhængigt er tre PRs.

| PR-type | Max ændrede filer (vejledende) |
|---------|-------------------------------|
| Bugfix | ~5 |
| Ny feature | ~15 |
| Refaktorering | ~20 |
| Ny komponent/modul | ~25 |

Store PRs gennemses overfladisk. Små PRs gennemses grundigt.

**Undtagelse:** Maskinelle ændringer (omdøbning, formatering, genererede
filer) kan fylde mange filer men gennemses som én enhed.

---

## Selvreview inden PR åbnes

Gennemgå din egen ændring inden du åbner PRen — læs diff'en linje for linje
som om du er reviewer. Det er den billigste måde at fange åbenlyse fejl.

Tjekliste til selvreview:

- [ ] Diff'en gør præcis det PR-beskrivelsen siger — intet mere, intet mindre
- [ ] Ingen debug-output, `println!`, `console.log` eller `TODO` uden issue-reference
- [ ] Ingen hardkodede værdier der burde være konfiguration
- [ ] Ingen hemmeligheder eller persondata i koden
- [ ] Tests er skrevet og passerer (`cargo test`, `pytest`, o.l.)
- [ ] `AGENTS.md` opdateret hvis stack, kommandoer eller arkitektur ændres
- [ ] `CHANGELOG.md` opdateret ved brugervendte ændringer

---

## Hvad reviewer tjekker

### Korrekthed
- Løser ændringen det den siger den løser?
- Er edge cases håndteret (tomt input, fejlstier, grænsetilfælde)?
- Er der regression-risiko i andre dele af systemet?

### Tests
- Er der tests til de nye code paths?
- Tester tests adfærd eller implementering? (adfærd er bedre)
- Ville testene fange en bug der introduceres her?

### Sikkerhed (OWASP-tjekliste fra ADR-0013)
- Ny brugerinput: valideret?
- Nye endpoints: auth-check som første handling?
- Nye DB-queries: parameteriserede?
- Nye værdier i DOM: escaped?

### Dokumentation
- Er ikke-åbenlyse valg kommenteret?
- Er `AGENTS.md` opdateret?
- Kræver ændringen en ny ADR? (se `process.md`)

### Kodekvalitet
- Er navngivningen klar og konsistent med resten af codebasen?
- Er der duplikering der kan undgås med et eksisterende abstraktionslag?
- Er fejlhåndtering eksplicit — ikke stille fejl der swallower exceptions?

---

## Definition of done

En PR er klar til merge når:

- [ ] CI er grøn (tests, lint, `cargo audit`)
- [ ] Selvreview-tjeklisten er gennemgået
- [ ] Mindst én reviewer har godkendt (ved open source-projekter)
- [ ] Review-kommentarer er adresseret eller eksplicit afvist med begrundelse
- [ ] `CHANGELOG.md` er opdateret (ved brugervendte ændringer)
- [ ] `AGENTS.md` er opdateret (ved tekniske ændringer der påvirker onboarding)
- [ ] Ingen åbne "blocker"-kommentarer fra reviewer

For personlige projekter uden ekstern reviewer: selvreview-tjeklisten
erstatter reviewer-godkendelse.

---

## AI-genererede PRs

AI-agenter kan åbne PRs, men de samme krav gælder. Ekstra opmærksomhed på:

- **Tests:** AI-agenter skriver tests der dækker happy path men glemmer
  fejlstier. Tjek aktivt at edge cases er dækket.
- **Scope-creep:** AI-agenter refaktorerer ofte udenfor scope. Tjek at
  diff'en kun indeholder hvad der blev bedt om.
- **AGENTS.md:** Agenter opdaterer ikke altid AGENTS.md. Tjek eksplicit.
- **Hemmelige værdier:** Tjek at ingen credentials er endt i koden selv om
  de ser uskyldige ud (hardkodede test-tokens, eksempel-API-nøgler).

Brug `/review`-kommandoen (eller tilsvarende i det brugte AI-værktøj) til
at bede agenten gennemgå sit eget output inden commit.

---

## Commit-beskeder

En god commit-besked forklarer *hvorfor* — ikke *hvad* (det fremgår af diff'en).

```
feat: tilføj rate limiting på login-endpoint

Forhindrer brute-force-angreb mod /auth/token. Bruger tower_governor
med 5 forsøg per minut per IP. Grænsen er konfigurérbar via RATE_LIMIT_RPM.
```

Format: `<type>: <kort beskrivelse>` (max 72 tegn i første linje).

Typer: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`.

Breaking changes markeres med `!` efter typen: `feat!: fjern deprecated endpoint`.

# Test og dokumentation

> **AI-agent? Læs først dette afsnit.**
> Inden du melder en opgave færdig: gå hele tjeklisten nedenfor igennem
> eksplicit og angiv for hvert punkt om det er opfyldt eller ej. Det er
> ikke nok at have læst guidelines passivt — du skal aktivt verificere.

## Tjekliste før commit

Den korte version. Detaljer i sektionerne nedenfor.

**Kode og test:**
- [ ] Tests skrevet som kørbar kode i projektets testmappe (ikke ad-hoc shell-kommandoer)
- [ ] Mindst én test for hvert grænsetilfælde (tomt input, ugyldige værdier, fejlstier) — ikke kun happy path
- [ ] Tests er deterministiske (ingen tilfældighed, systemtid mockes, ingen afhængighed mellem tests)
- [ ] Projektets test-kommando passerer rent (`cargo test`, `uv run pytest`, eller tilsvarende)
- [ ] Integration tests prioriteres over mocks for database-/IO-logik

**Dokumentation:**
- [ ] `AGENTS.md` opdateret i samme commit, hvis ændringen påvirker stack, kommandoer eller ikke-åbenlyse detaljer
- [ ] README / brugervendte docs opdateret hvis brugerflader (CLI-flag, slash-kommandoer, output-format) ændres
- [ ] Kommentarer kun til det ikke-åbenlyse — skjulte constraints, workarounds, invarianter. Ikke "hvad gør koden"
- [ ] ADR i `~/projects/adrs/` ved arkitektoniske valg, linket fra `AGENTS.md`

**Sikkerhed:**
- [ ] Hver `unsafe`-blok har en SAFETY-kommentar der forklarer hvorfor den er sikker
- [ ] Ingen hemmeligheder (API-nøgler, tokens) committed; brug env-vars eller config-filer ekskluderet via `.gitignore`

## Test

### Tests skrives som kode — aldrig som engangskommandoer

Tests skal altid skrives som kørbar kode i projektets testmappe (`tests/`, `src/`, eller tilsvarende) — ikke som inline shell-kommandoer der køres én gang og smides væk. En test der ikke kan genafvikles er ikke en test, men en manuel verifikation.

Når en ny feature implementeres: skriv testene i samme commit. Kørbarhed verificeres med `uv run pytest`, `cargo test`, eller projektets testkommando.

### Dæk de tre niveauer

- **Unit tests** — isolerede funktioner og datamodeller; ingen I/O, ingen netværk
- **Integration tests** — flere komponenter sammen; rammer rigtig database/filesystem, ikke mocks
- **End-to-end tests** — brugerflows fra frontend til backend (Playwright eller tilsvarende)

Prioritér integration tests over unit tests for backend-logik der rører databasen — mocks har gentagne gange maskeret fejl der først dukkede op i produktion.

### Test grænsetilfælde, ikke kun happy path

For hver funktion: hvad sker der ved tomt input, ugyldige værdier, manglende tilladelser, og netværksfejl? Skriv mindst én test per grænsetilfælde der har kostet bugs i produktion.

### Tests skal være deterministiske

Ingen tilfældig rækkefølge, ingen afhængighed af systemtid uden at mocke den, ingen afhængighed af andre tests. En test der sommetider fejler er værre end ingen test.

### Post-deploy smoke test

Kør en minimal smoke test mod produktion efter hvert deploy der verificerer at de vigtigste endpoints svarer korrekt. Fejl i smoke testen skal stoppe deployet.

### Hvert miljø skal have sin egen database

Når test, beta og produktion deler én PostgreSQL-container, skal de bruge **separate databaser** — ikke den samme. E2e-tests opretter og sletter data; hvis de rammer prod-databasen direkte, forurenes den med testbrugere og testrumsnavne.

```yaml
# docker-compose.prod.yml
chat-test:
  environment:
    DATABASE_URL: postgres://...@postgres:5432/chatdb_test  # ikke chatdb
```

Psql-gotcha: `CREATE DATABASE` skal forbinde til en eksisterende database. Brug maintenance-databasen:
```bash
psql -U chatuser -d postgres -c "CREATE DATABASE chatdb_test"
# -d postgres er påkrævet — chatuser-databasen eksisterer ikke per default
```

### E2e-tests skal rydde op efter sig

Slet testbrugere og testdata via API'et efter hvert testforløb — ikke direkte i databasen. Brug `DELETE /auth/me` (eller tilsvarende) i `afterEach`/`afterAll`. Forudsætter at API'et understøtter GDPR-sletning.

## Dokumentation

### AGENTS.md er den primære kilde

Hold `AGENTS.md` opdateret med stack, arkitektur, kommandoer og ikke-åbenlyse detaljer. Det er den første fil en ny agent (eller udvikler) læser.

### Kommenter kun det ikke-åbenlyse

Skriv ikke kommentarer der beskriver hvad koden gør — det gør velnavngivne funktioner og variabler. Skriv kun kommentarer til:
- Skjulte constraints ("skal køres før X pga. Y")
- Workarounds for specifikke bugs
- Invarianter der ikke fremgår af typen

### ADR ved arkitektoniske valg

Træffes et valg der ikke er oplagt (framework, protokol, dataformat, sikkerhedsstrategi), skrives en ADR i `~/projects/adrs/` og linkes fra `AGENTS.md`. Det forhindrer at den samme diskussion tages igen.

### Opdatér dokumentation i samme commit som koden

Dokumentation der lagger efter koden er vildledende. Hvis en ændring påvirker arkitektur, kommandoer eller ikke-åbenlyse detaljer i `AGENTS.md`, opdateres filen i samme commit.

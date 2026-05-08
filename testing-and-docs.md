# Test og dokumentation

## Test

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

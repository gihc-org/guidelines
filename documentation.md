# Dokumentation — hvad, hvor og hvornår

Hvad der dokumenteres, hvor det hører hjemme, og hvornår det opdateres.
Se `knowledge-management.md` for det overordnede hierarki over videnstyper.

## Hvad hører hjemme hvor

| Indhold | Destination |
|---------|-------------|
| Stack, arkitektur, kommandoer, ikke-åbenlyse detaljer | `AGENTS.md` |
| Installering, brug, bidrag — til eksterne læsere | `README.md` |
| Arkitektoniske valg og begrundelser | `~/projects/adrs/` |
| Generelle mønstre der gælder på tværs af projekter | `~/projects/guidelines/` |
| Projektspecifik kontekst der ikke passer andre steder | `./kontekst/` |
| Sessionsresumé til næste AI/menneske | `./referater/` |
| Inline i koden | Kun til det ikke-åbenlyse (se nedenfor) |

Beslut destination i denne rækkefølge:
1. Kan det generaliseres til andre projekter? → `guidelines/`
2. Er det et arkitektonisk valg? → `adrs/`
3. Er det et sessionsresumé? → `referater/`
4. Er det projektspecifik kontekst? → `kontekst/` eller `AGENTS.md`

---

## AGENTS.md

`AGENTS.md` er den primære kilde for AI-agenter og nye bidragydere. Den
læses ved sessionens start og skal give nok kontekst til at arbejde uden
at spørge om basale ting.

**Skal indeholde:**
- Projektbeskrivelse (én sætning)
- Stack med versioner der betyder noget
- Arkitekturoversigt (ASCII-diagram eller kort tekst)
- Kommandoer: hvordan man kører, tester og deployer
- Links til relevante ADRs
- Ikke-åbenlyse gotchas og constraints

**Skal ikke indeholde:**
- Alt hvad der fremgår af koden
- Detaljeret API-dokumentation (hører i koden eller en separat fil)
- Duplikering af README-indhold

**Opdateres i samme commit som koden** hvis ændringen påvirker stack,
kommandoer, arkitektur eller ikke-åbenlyse detaljer. Dokumentation der
lagger efter koden er vildledende.

---

## README.md

README er til eksterne læsere: bidragydere, brugere, fremtidige ejere.
Den besvarer på under 30 sekunder: hvad er det, virker det, og hvordan
kommer jeg i gang?

Se `open-source.md` for obligatoriske sektioner og skabelon.

**README vs. AGENTS.md:** README er menneskelig onboarding. AGENTS.md er
AI-/udvikler-onboarding med tekniske detaljer. De overlapper bevidst lidt —
gentag hellere de vigtigste kommandoer begge steder end at tvinge læseren
til at hoppe frem og tilbage.

---

## Inline-kommentarer

Skriv ikke kommentarer der beskriver hvad koden gør — det gør velnavngivne
funktioner og variabler. Skriv kun en kommentar til:

- **Skjulte constraints:** `// Skal køres inden X pga. Y`
- **Workarounds for specifikke bugs:** `// rustc 1.88 lifetime-regression, se ADR-0005`
- **Invarianter der ikke fremgår af typen:** `// Altid sorteret; binær søgning afhænger heraf`
- **Ikke-åbenlyse sikkerhedsvalg:** `// Konstant-tids sammenligning — undgår timing-angreb`

**Grænsen:** Hvis du kan slette kommentaren og en fremtidig læser ikke ville
savne den — slet den.

Undgå:
- Kommentarer der beskriver hvad næste linje gør
- `// TODO` uden issue-reference (brug i stedet en issue-tracker)
- Udkommenteret kode — slet det, git har historikken

---

## ADR vs. guideline

| Spørgsmål | Svar |
|-----------|------|
| Dokumenterer vi et konkret valg vi traf (framework, protokol, dataformat)? | ADR |
| Dokumenterer vi et mønster der skal følges fremover? | Guideline |
| Er det specifikt for ét projekt? | ADR i projektet eller `~/projects/adrs/` |
| Kan det bruges på tværs af projekter? | `~/projects/guidelines/` |

Eksempel: "Vi valgte Axum frem for Actix-web" → ADR. "Sådan strukturerer
vi en Rust-backend generelt" → guideline.

---

## API-dokumentation

For projekter der eksponerer en HTTP API:

- **Intern brug:** API-oversigt i `AGENTS.md` (metode, sti, auth-krav).
- **Ekstern/public API:** OpenAPI/Swagger-spec i `openapi.yaml` eller
  genereret fra koden.
- **Ændringer til API** dokumenteres i `CHANGELOG.md` — breaking changes
  fremhæves eksplicit.

---

## Sessionsreferater

Skriv et kort referat ved afslutningen af hver arbejdssession i
`./referater/YYYY-MM-DD-HH-MM.md`. Se `process.md` for format og indhold.

Referater er ikke valgfrie i aktive projekter — de er det eneste der giver
næste sessions AI og menneske et fælles udgangspunkt uden at genlæse hele
git-historikken.

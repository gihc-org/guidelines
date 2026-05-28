# Open source — licens, dokumentation og bidragspraksis

Krav til projekter der udgives som frit software. Målet er at en dygtig
udvikler kan adoptere, afvikle og bidrage til projektet uden at skulle
spørge om hjælp til de basale ting.

## Licens

**Alle projekter bruger AGPL-3.0** medmindre der er en konkret begrundelse
for andet.

AGPL-3.0 er valgt fordi:
- Det er copyleft: afledte værker skal udgives under samme vilkår.
- Network use clause: den der tilbyder softwaren som en tjeneste skal også
  frigive kildekoden — i modsætning til GPL, der ikke dækker dette.
- Det er kompatibelt med FSF's definition af fri software.

`LICENSE`-filen skal ligge i roden af repoet. Brug SPDX-identifikatoren
`AGPL-3.0-only` i `Cargo.toml`, `pyproject.toml` eller tilsvarende:

```toml
# Cargo.toml
license = "AGPL-3.0-only"
```

Brug ikke `AGPL-3.0-or-later` medmindre du eksplicit ønsker at tillade
fremtidige AGPL-versioner.

## Obligatoriske filer i roden

| Fil | Krav | Indhold |
|-----|------|---------|
| `LICENSE` | Altid | AGPL-3.0-teksten |
| `README.md` | Altid | Se skabelon nedenfor |
| `CONTRIBUTING.md` | Inden første offentlige release | Se skabelon nedenfor |
| `SECURITY.md` | Inden første offentlige release | Ansvarlig afsløring |
| `CHANGELOG.md` | Inden første offentlige release | Keep a Changelog-format |

`CODE_OF_CONDUCT.md` er valgfrit for enkeltpersons-projekter, men anbefales
ved projekter der aktivt søger bidragydere.

---

## README.md

Et godt README besvarer på under 30 sekunder: hvad er det, virker det, og
hvordan kommer jeg i gang?

Obligatoriske sektioner:

```markdown
# <projektnavn>

<Én sætning: hvad gør projektet og for hvem.>

## Status

<Tabel eller tekst der angiver projektets modenhed: alfa/beta/stabil,
hvilke funktioner er klar, hvad er under udvikling.>

## Kom i gang

<Præcise trin fra nul til kørende instans. Inkludér forudsætninger.>

    git clone …
    cp .env.example .env
    docker compose up --build

## Brug

<De vigtigste use cases med eksempler. CLI: vis hjælpetekst. API: vis
et eksempel-request. UI: screenshot eller kort beskrivelse.>

## Bidrag

Se [CONTRIBUTING.md](CONTRIBUTING.md).

## Licens

[AGPL-3.0-only](LICENSE)
```

Skriv README på engelsk hvis projektet henvender sig til et internationalt
publikum. Dansk er fint til projekter der udelukkende er til intern brug.

---

## CONTRIBUTING.md

```markdown
# Bidrag til <projektnavn>

## Rapportér en fejl

Brug GitHubs issue-tracker. Inkludér:
- Hvad du forventede skulle ske
- Hvad der faktisk skete
- Trin til at reproducere det
- Platformsinfo (OS, version af projektet)

## Foreslå en ændring

Åbn et issue før du skriver kode til større ændringer — så undgår vi at
du bruger tid på noget der ikke passer ind.

## Send en patch

1. Fork repoet og opret en branch: `git checkout -b mit-fix`
2. Skriv tests til din ændring (se `AGENTS.md` for test-krav)
3. Sørg for at test-suiten passerer: `<testkommando>`
4. Åbn en pull request mod `main`

## Kode-stil

Følg projektets eksisterende stil. Linting køres automatisk i CI.

## Licens

Ved at bidrage accepterer du at dit bidrag udgives under projektets
AGPL-3.0-only-licens.
```

Tilpas `<testkommando>` til projektet (`cargo test`, `uv run pytest`, osv.).

---

## CHANGELOG.md

Brug [Keep a Changelog](https://keepachangelog.com/da/1.0.0/)-formatet med
[Semantic Versioning](https://semver.org/lang/da/).

```markdown
# Changelog

Alle væsentlige ændringer dokumenteres her.

Format: [Keep a Changelog](https://keepachangelog.com/da/1.0.0/)
Versionering: [Semantic Versioning](https://semver.org/lang/da/)

## [Unreleased]

### Tilføjet
### Ændret
### Fjernet
### Rettet
### Sikkerhed

## [1.0.0] - YYYY-MM-DD

### Tilføjet
- Første stabile release
```

**Regler:**
- Hold `[Unreleased]`-sektionen opdateret løbende — ikke kun ved release.
- Skriv til brugeren, ikke til udvikleren. "Tilføjet login med e-mail" er
  bedre end "Implementeret AuthHandler i auth.rs".
- Sikkerhedsrettelser havner altid i `### Sikkerhed`, aldrig kun i `### Rettet`.

---

## SECURITY.md

```markdown
# Sikkerhedspolitik

## Understøttede versioner

| Version | Understøttet |
|---------|-------------|
| latest  | ✅ |

## Rapportér en sårbarhed

Send en e-mail til <din-email> med:
- Beskrivelse af sårbarheden
- Trin til at reproducere den
- Potentiel påvirkning

Forventet svartid: 5 arbejdsdage.

Offentliggør ikke sårbarheden offentligt før vi har haft mulighed for
at rette den (coordinated disclosure).
```

Erstat `<din-email>` med en reel adresse. GitHub understøtter også
private security advisories under Settings → Security → Advisories.

---

## Checkliste inden første offentlige release

- [ ] `LICENSE` (AGPL-3.0-only) i roden
- [ ] `README.md` med alle obligatoriske sektioner
- [ ] `CONTRIBUTING.md`
- [ ] `SECURITY.md` med kontaktadresse
- [ ] `CHANGELOG.md` med mindst en `[Unreleased]`-sektion
- [ ] `license`-felt i `Cargo.toml` / `pyproject.toml`
- [ ] `.gitignore` ekskluderer `.env`, nøgler og build-artefakter
- [ ] Ingen hemmeligheder i git-historikken (`git log` + `git grep`)
- [ ] CI kører tests og lint ved pull request

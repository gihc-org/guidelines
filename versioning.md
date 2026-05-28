# Versionering og releases

Konvention for versionsnumre, git-tags og GitHub-releases på tværs af projekter.

## SemVer vs. CalVer

| Projekttype | Anbefaling | Eksempel |
|-------------|-----------|---------|
| Bibliotek eller API andre afhænger af | **SemVer** | `1.4.2` |
| CLI-værktøj eller app til slutbrugere | **SemVer** | `0.8.0` |
| Personlig app / intern tjeneste | **CalVer** (valgfrit) | `2026.05` |
| Infra-konfiguration uden public API | Ingen versionering nødvendig | — |

Tvivl? Brug SemVer — det er det mest genkendelige format og tvinger dig til
at tage stilling til breaking changes.

---

## Semantic Versioning (SemVer)

Format: `MAJOR.MINOR.PATCH` — f.eks. `1.4.2`.

| Bump | Hvornår |
|------|---------|
| `PATCH` | Bagudkompatibel bugfix |
| `MINOR` | Ny bagudkompatibel funktionalitet |
| `MAJOR` | Breaking change — eksisterende brugere skal tilpasse sig |

### Hvad er en breaking change?

- Fjernelse eller omdøbning af et offentligt API-endpoint, funktion eller flag
- Ændring af request/response-format på et eksisterende endpoint
- Ændring af database-skema der kræver manuel migration
- Ændring af konfigurationsformat (env vars, config-fil)
- Fjernelse af en feature

Tilføjelse af nye endpoints, felter eller funktioner er **ikke** breaking
(bagudkompatibelt).

### Startversion

Nye projekter starter på `0.1.0`. `0.x`-versioner signalerer at public API
ikke er stabilt — breaking changes tillades i MINOR-bump. `1.0.0` er første
stabile release.

---

## Calendar Versioning (CalVer)

Format: `YYYY.MM` eller `YYYY.MM.DD` — f.eks. `2026.05`.

Egner sig til interne tjenester og personlige apps hvor "breaking change"
er mindre meningsfuld fordi der kun er én instans og én ejer.

Bruges **ikke** til biblioteker eller projekter med eksterne brugere.

---

## Git-tags

Alle releases tagges i git. Tag-formatet er `v` + versionsnummeret:

```bash
git tag v1.4.2
git push origin v1.4.2
```

Tag aldrig direkte på en work-in-progress branch — tag på `main`/`trunk`
efter merge.

Annoterede tags foretrækkes ved offentlige releases (inkluderer besked og
tagger):

```bash
git tag -a v1.4.2 -m "Release 1.4.2 — se CHANGELOG.md"
git push origin v1.4.2
```

---

## CHANGELOG.md

CHANGELOG opdateres **inden** release-tagget sættes. Se `open-source.md`
for format (Keep a Changelog).

Arbejdsgang:

1. Flyt indhold fra `[Unreleased]` til en ny `[1.4.2] - YYYY-MM-DD`-sektion
2. Tilføj link til diff øverst: `[1.4.2]: https://github.com/…/compare/v1.4.1...v1.4.2`
3. Commit: `chore: release 1.4.2`
4. Tag: `git tag -a v1.4.2 -m "Release 1.4.2"`
5. Push commit og tag: `git push && git push origin v1.4.2`

---

## GitHub Releases

Opret en GitHub Release ved:
- Første stabile release (`1.0.0`)
- MAJOR- og MINOR-bumps
- Releases med binære artefakter (kompilerede binærer, Docker-images)

PATCH-bumps kan nøjes med et git-tag uden GitHub Release.

```bash
gh release create v1.4.2 --title "v1.4.2" --notes-from-tag
```

Eller brug GitHub-webinterfacet og kopier CHANGELOG-sektionen ind.

---

## Pre-release

Format: `MAJOR.MINOR.PATCH-<label>.<nummer>` — f.eks. `1.0.0-beta.1`.

| Label | Hvornår |
|-------|---------|
| `alpha` | Tidlig test — API kan ændre sig |
| `beta` | Feature-komplet, bugfixes mangler |
| `rc` (release candidate) | Klar til release hvis ingen kritiske fejl |

```bash
git tag v1.0.0-rc.1
git push origin v1.0.0-rc.1
```

Pre-release tags markeres som pre-release i GitHub Releases så de ikke
vises som "Latest release" for slutbrugere.

---

## Versionsnummer i kildekode

Opdatér versionsnummeret i projektets manifest i samme commit som CHANGELOG:

```toml
# Cargo.toml
[package]
version = "1.4.2"
```

```toml
# pyproject.toml
[project]
version = "1.4.2"
```

For projekter der bruger `git describe` eller CI-genererede versioner
behøver manifestet ikke manuelt opdateres — dokumentér dette i `AGENTS.md`.

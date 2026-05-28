# CI/CD — obligatoriske checks og deploy-pipeline

Definition af hvad der altid skal køre i CI, hvornår det blokerer, og
hvordan infrastruktur- og applikationsdeploy adskilles. Se ADR-0017 for
Ansible-specifik implementering af infra/deploy-opdelingen.

## Obligatoriske CI-checks

Alle checks herunder køres ved hvert pull request og ved push til
`main`/`trunk`. Et mislykket check blokerer merge/deploy.

| Check | Hvornår | Blokerer | Værktøj (eksempel) |
|-------|---------|----------|-------------------|
| Enhedstests | PR + push | Ja | `cargo test`, `pytest`, `go test` |
| Integrationstests | PR + push | Ja | `cargo test` + testdatabase |
| Lint / formatering | PR + push | Ja | `cargo clippy`, `ruff`, `golangci-lint` |
| Afhængighedssårbarhed | PR + push | Ja | `cargo audit`, `pip-audit`, `npm audit` |
| Konfigurations-validering | Push til staging/prod | Ja | `caddy validate`, `ansible-lint` |
| OWASP ZAP baseline scan | Deploy til staging | Ja | OWASP ZAP (Docker) |
| E2e-tests | Deploy til staging | Ja | Playwright, `cargo test` + live server |
| Smoke test | Deploy til prod | Ja | Projekteget `scripts/smoke-test.sh` |

`cargo audit` og `pip-audit` med **kritiske** sårbarheder behandles som
fejlede builds — ikke advarsler. Moderate sårbarheder logges og trackedes
som issues, men blokerer ikke.

## Hvad der ikke må slippes igennem

Følgende er blokkende fejl uanset kontekst:

- Tests der fejler
- Lint-fejl (ikke advarsler — konfigurér lint til at skelne)
- Hemmelige nøgler eller credentials committet til git
  (`git-secrets`, `trufflehog` eller tilsvarende som pre-commit hook)
- Kritiske CVEs i afhængigheder

## Pipeline-struktur

### PR-pipeline (hurtig feedback)

```
push → lint → unit tests → integration tests → afhængighedssårbarhed
```

Mål: under 3 minutter. Undgå tunge operationer (Docker build, e2e) her.

### Staging-deploy

```
merge til main → byg Docker-image → deploy til staging
  → konfigurations-validering → e2e-tests → OWASP ZAP
  → [manuelt godkend] eller [automatisk til prod]
```

### Prod-deploy

```
godkend staging → deploy til prod → smoke test → [rollback ved fejl]
```

Smoke testen er sidste vagt. Fejler den, stoppes deployet og forrige
version genindsættes.

## Infra vs. applikationsdeploy

Hold infrastruktur-ændringer (OS-pakker, Docker-installation, firewall) og
applikationsdeploy (kode, config, containers) adskilt:

- **Infra-ændringer** køres manuelt og bevidst — aldrig automatisk fra CI.
- **Applikationsdeploy** køres automatisk fra CI ved merge til `main`.

CI-pipeline har kun adgang til at køre applikationsdeploy. Infra-adgang kræver
eksplicit menneskelig handling. Se ADR-0017 for Ansible-implementeringen.

## Miljø-strategi

| Miljø | Formål | Database | Hvem deployer |
|-------|--------|----------|--------------|
| Lokal | Udvikling | Lokal / `docker compose up` | Udvikler |
| Test (CI) | Automatiske checks | In-memory / container | CI-pipeline |
| Staging | Verifikation inden prod | Separat — ikke prod-data | CI automatisk |
| Prod | Slutbrugere | Prod-database | CI (efter staging) |

Test- og staging-databaser deler aldrig data med produktion.

## Secrets i CI

- Secrets injiceres som miljøvariabler fra CI-systemets secret store —
  aldrig hardkodet i pipeline-konfigurationen.
- `.env`-filer committes aldrig — kun `.env.example` med pladsholdere.
- Vault-passwords til Ansible kræver eksplicit input ved manuelle kørsel
  (`--ask-vault-pass`) — ikke embedded i pipeline.
- Se ADR-0026 for generel secrets-strategi.

## Konfigurations-validering

Konfigurationer der genereres dynamisk (Caddyfile, Nginx-config,
docker-compose-overrides) valideres inden deploy:

```bash
caddy validate --config /etc/caddy/Caddyfile
ansible-lint ansible/deploy.yml
docker compose config --quiet
```

En ugyldig konfiguration der deployes til prod er en uplanlagt nedetid.
Validering koster sekunder og forhindrer det scenarie.

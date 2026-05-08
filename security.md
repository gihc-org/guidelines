# Sikkerhed og compliance — generelle principper

## Password hashing: Argon2id

Brug `Argon2::default()` (m=19456, t=2, p=1) — ikke bcrypt eller scrypt. Argon2id er OWASP-anbefalet og modstandsdygtig over for GPU-angreb.

## OWASP Top 10 som del af definition of done

Gennemgå OWASP Top 10 ved implementering af nye features:
- Injection (SQL, kommando, LDAP)
- Broken authentication / session management
- Sensitive data exposure (kryptering, logging)
- Security misconfiguration (headers, CORS, fejlbeskeder)
- XSS og CSRF på frontend
- Insecure deserialization
- Rate limiting på auth-endpoints

## Tom env-variabel som feature flag

Brug fravær af env-variabel (tom streng) som signal om at en integration skal springes over i lokal udvikling:

```rust
if config.turnstile_secret.is_empty() { /* skip CAPTCHA */ }
```

Undgår behovet for separate config-filer eller boolean flags. Fungerer med 12-factor-princippet.

## GDPR: ret til sletning og indsigt

Enhver app der gemmer persondata skal implementere:
- `DELETE /auth/me` (eller tilsvarende) — sletter bruger og alle tilknyttede data via CASCADE
- `GET /auth/me` — returnerer alle gemte felter

Undgå at gemme opkaldsmetadata, session-logs og lignende uden eksplicit behov — GDPR-implikationerne er større end fordelen.

## CIS Docker Benchmark

Ved nye Docker-services:
- Kør container som non-root bruger (`USER appuser`)
- Sæt resource limits (`memory`, `cpus`)
- `no-new-privileges: true`
- `read_only: true` hvor muligt
- Scan image med `docker scout cves` eller `trivy` efter build

## JWT

- Brug HS256 med et stærkt random secret (min. 256 bit)
- WebSocket auth via query-parameter (`?token=<jwt>`) — browser kan ikke sætte custom headers på WS upgrade
- Overvej `httpOnly`-cookie frem for `localStorage` for at reducere XSS-risiko

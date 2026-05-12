# Ansible deploy — mønstre og gotchas

## Vent på DNS-propagering før Caddy genindlæses

Når nye A-records oprettes via Simply.com API'et, er de ikke umiddelbart synlige for
eksterne resolvere — herunder Let's Encrypts og ZeroSSLs ACME-servere. Hvis Caddy
genindlæses for tidligt, forsøger den at hente TLS-certifikater mens domænet stadig
returnerer NXDOMAIN hos ACME-serverne. Udstedelsen fejler, og Caddy går i backoff.

**Løsning:** Tilføj et DNS-propagerings-vent efter oprettelse af A-records og før
`caddy reload`. Poll en ekstern resolver (f.eks. `8.8.8.8`) indtil alle nye domæner
resolver korrekt:

```yaml
- name: Vent på DNS-propagering for nye domæner
  ansible.builtin.command:
    cmd: dig @8.8.8.8 {{ item }} +short
  loop:
    - "example.apps.gihc.online"
    - "api.gihc.online"
  register: dns_check
  retries: 18
  delay: 10
  until: dns_check.stdout != ""

- name: Genindlæs platform Caddy
  ansible.builtin.command:
    cmd: docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile
    chdir: "{{ platform_dir }}"
```

Uden dette vent virker første deploy af et nyt domæne tilsyneladende — smoke tests
mod API'et består fordi API-certifikater udstedes hurtigt — men frontenden fejler med
`SSL_ERROR_INTERNAL_ERROR_ALERT` indtil Caddy's automatiske retry-mekanisme slår
igennem (kan tage mange minutter).

## Lokal DNS-cache kan skjule at records er oprettet

Selv efter en vellykket `caddy reload` og korrekt ACME-udstedelse kan browseren vise
"Server Not Found" fordi den lokale router har cachet et negativt DNS-svar (NXDOMAIN)
fra før A-recorden eksisterede.

Diagnosticér ved at spørge direkte mod Simply.coms navneserver:

```bash
dig @ns1.simply.com example.apps.gihc.online
```

Hvis recorden er der, er det et lokalt cache-problem. Løsning: genstart routeren eller
skift midlertidigt DNS-server til `1.1.1.1`.

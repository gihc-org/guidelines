# guidelines

Generelle kodningsregler og mønstre til brug på tværs af projekter. Designet til at blive læst af AI-coding-agents (Claude Code, DeepSeek m.fl.) via `AGENTS.md`.

## Indhold

| Fil | Indhold |
|-----|---------|
| [testing-strategy.md](testing-strategy.md) | Testniveauer, dækningskrav, mocking-principper, OWASP-sikkerhedstests |
| [open-source.md](open-source.md) | Licens (AGPL-3.0), README, CONTRIBUTING, CHANGELOG, SECURITY |
| [security.md](security.md) | Argon2id, OWASP, GDPR, CIS Docker, JWT, feature flags |
| [rust-axum.md](rust-axum.md) | Axum, SQLx, rustls, lib/bin-split, WebSocket-auth |
| [webrtc.md](webrtc.md) | TURN/STUN, rejoin-håndtering, delt RTCPeerConnection, opkalds-flow |
| [web-frontend.md](web-frontend.md) | CSS/JS-gotchas, autoplay, MediaStream |
| [testing-and-docs.md](testing-and-docs.md) | AI-vendt commit-tjekliste for test og dokumentation |
| [process.md](process.md) | Features i TODO før implementering; ADR/guideline-vurdering efter commit |
| [claude-code.md](claude-code.md) | Claude Code hooks: referat-påmindelse ved sessionslut |
| [ansible-deploy.md](ansible-deploy.md) | DNS-propagering, Caddy TLS-timing, lokal cache-diagnostik |

## Brug i et nyt projekt

```bash
git clone https://github.com/gihc-org/guidelines ~/projects/guidelines
cd ~/projects/mit-projekt
bash ~/projects/guidelines/new-project-setup.sh
```

Scriptet opretter:
- `.guidelines` — symlink til denne mappe (gitignored)
- `AGENTS.md` — udfyldt fra `AGENTS.template.md`
- `CLAUDE.md` — importerer `AGENTS.md` via `@AGENTS.md`

Fjern de `@.guidelines/`-linjer i `AGENTS.md` der ikke er relevante for projektet.

## Tilføj en ny regel

Skriv reglen i den relevante fil og commit. Alle projekter der bruger symlinket får den automatisk ved næste `git pull`.

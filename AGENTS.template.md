# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## Generelle guidelines

<!-- Inkludér de guidelines der er relevante for projektet. Fjern de andre. -->
@.guidelines/security.md
@.guidelines/rust-axum.md
@.guidelines/webrtc.md
@.guidelines/web-frontend.md
@.guidelines/testing-and-docs.md

---

## Projektbeskrivelse

<!-- Én sætning: hvad gør projektet, og hvem bruger det? -->
<!-- Eksempel: "REST API til håndtering af ordrer for interne brugere." -->

## Stack

<!-- Liste over teknologier og frameworks. Vær specifik om versioner der betyder noget. -->
<!-- Eksempel:
- **Backend:** Rust, Axum 0.7, SQLx 0.8 + PostgreSQL
- **Frontend:** Vanilla JS — ingen framework
- **Deploy:** Docker Compose, Ansible, Caddy
-->

## Arkitektur

<!-- Kort beskrivelse eller ASCII-diagram over komponenterne og deres relationer. -->
<!-- Eksempel:
```
Frontend (IPFS/CDN)
    └── api.example.com  →  Caddy  →  backend:8001 (Axum)
                                            │
                                        PostgreSQL
```
-->

## Kom i gang

<!-- Trin-for-trin: hvad skal man gøre for at køre projektet lokalt? -->
<!-- Eksempel:
```bash
cp .env.example .env
docker compose up --build
```
-->

## Vigtige filer og moduler

<!-- Tabel eller liste over de vigtigste filer/moduler og hvad de gør. -->
<!-- Eksempel:
| Fil | Formål |
|-----|--------|
| `src/lib.rs` | Lib-root — eksporterer AppState, router og middleware |
| `src/routes/auth.rs` | Login, registrering, JWT |
| `frontend/chat.html` | Hoved-UI med WebSocket og WebRTC |
-->

## API-oversigt

<!-- Hvis projektet eksponerer en API: metode, sti og auth-krav. -->
<!-- Eksempel:
| Metode | Sti | Auth |
|--------|-----|------|
| POST | /auth/register | — |
| GET  | /rooms | Bearer |
| WS   | /ws/:id?token= | query param |
-->

## Nøglebeslutninger

<!-- Links til ADR'er der gælder for projektet. -->
<!-- ADR'er ligger i ~/projects/adrs/ -->
<!-- Eksempel:
| ADR | Beslutning |
|-----|------------|
| [0001](~/projects/adrs/0001-axum-over-actix.md) | Axum over Actix-web |
| [0011](~/projects/adrs/0011-argon2id-passwords.md) | Argon2id til password-hashing |
-->

## Projekt-specifikke detaljer

<!-- Non-obvious ting der ikke fremgår af koden eller ADR'erne: -->
<!-- - Quirks ved tredjeparts-API'er -->
<!-- - Særlige krav til testopsætning -->
<!-- - Kendte gotchas der har kostet tid -->

# Rust + Axum — generelle mønstre

## Framework: Axum over Actix-web

Axum er tættere integreret med Tokio-økosystemet, bruger Tower middleware direkte og har bedre ergonomi for extractors. Actix har sit eget actor-system der er unødvendigt komplekst for typiske REST/WebSocket-backends.

## SQLx: brug runtime API, ikke compile-time makroer

Brug `sqlx::query()` og `.fetch_one()` / `.fetch_all()` osv. — ikke `query!` eller `query_as!` makroerne.

Compile-time makroerne kræver en live database ved byggetid og giver fejl i CI/CD uden database. Runtime API er fleksibelt, testbart og fungerer med `#[sqlx::test]`.

## TLS: rustls over native-tls

Brug `rustls` (feature `rustls-tls` i reqwest og sqlx). Undgå `native-tls` og OpenSSL — det kræver system-afhængigheder der komplicerer Docker-builds og cross-compilation.

## Lib + bin split for testbarhed

Lib-crate (`src/lib.rs`) ejer alle moduler og eksporterer app-state og router. Bin-crate (`src/main.rs`) er et tyndt entrypoint der kalder lib. Integration tests kan dermed importere crate'en direkte uden at starte en proces.

## `authenticate` som plain async fn, ikke `FromRequestParts`

Rust 1.88 strammede lifetime-regler for async fns i traits — `FromRequestParts`-implementeringer der kalder async-kode kan fejle med lifetime-fejl. En plain `async fn authenticate(state, headers) -> Result<User>` er enklere, testbar og undgår problemet.

## WebSocket auth via query-parameter

Browseren kan ikke sætte custom headers på en WebSocket upgrade-request. Send JWT som `?token=<jwt>` i URL'en. Validér token'et i WS-handleren inden forbindelsen accepteres.

## In-memory broadcast channel per rum

`tokio::sync::broadcast` per rum giver effektiv fan-out til alle forbundne klienter uden ekstern message broker. Gem channels i en `Arc<Mutex<HashMap<RoomId, Sender>>>` i app-state.

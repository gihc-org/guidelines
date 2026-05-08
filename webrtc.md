# WebRTC — generelle mønstre

## Signalering over eksisterende WebSocket

Brug den eksisterende WebSocket-kanal til signalering (offer/answer/ICE-kandidater). Backenden er en dumb relay der broadcaster til rummet — den forstår ikke indholdet. `from`-feltet tilføjes af backenden ud fra den autentificerede bruger, så klienten ikke kan forfalske afsender-identiteten.

## STUN + TURN

STUN alene fejler for brugere bag symmetrisk NAT. Brug altid en TURN-server (coturn) som fallback.

**TURN-autentificering:** Brug `--use-auth-secret` med HMAC-SHA1 — ikke `--lt-cred-mech` med plaintext passwords (coturn forventer MD5-hash af `username:realm:password` som nøgle, hvilket er svært at generere korrekt i browser). Frontendens genererer tidsbegrænsede credentials via SubtleCrypto:

```javascript
const expires = Math.floor(Date.now() / 1000) + 86400;
const username = String(expires);
// credential = base64(HMAC-SHA1(TURN_SECRET, username))
```

TURN_SECRET må kun indeholde alfanumeriske tegn — specialtegn kan give HMAC-mismatch.

## Rejoin-håndtering: tidsbaseret guard

`RTCPeerConnection.connectionState` forbliver `'connected'` i ~30 sekunder efter at peeren er gået. Brug ikke connectionState som guard for om et nyt offer skal sendes — brug i stedet et timestamp:

```javascript
if (Date.now() - lastOfferTime < 3000) return; // undgå race condition
```

Send automatisk nyt offer når peeren vender tilbage (via `join`-besked i WS).

## Delt RTCPeerConnection via renegotiering

Til 1:1-rum: del én `RTCPeerConnection` mellem flere medietyper (fx skærmdeling + lydopkald) via `addTrack()` / `removeTrack()` og renegotiering (`onnegotiationneeded`). To separate PC'er fordobler TURN-allokering og ICE-udveksling uden fordel.

Ved renegotiering: detect at PC allerede er forbundet (`pc.connectionState === 'connected'`) og spring `createPeerConnection()` over.

## Opkald: send offer efter accept, ikke med det samme

Caller sender ikke WebRTC offer ved `call-invite` — først når callee sender `call-accept`. Undgår ICE-gathering og TURN-allokering for opkald der afvises.

Signal-flow:
```
call-invite → call-accept/call-reject → offer → answer → ICE-kandidater → call-end
```

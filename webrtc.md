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

## DataChannels på en delt RTCPeerConnection: onnegotiationneeded + pendingOffer

Når en `RTCDataChannel` oprettes på en PC der allerede er forbundet for media (screen share / audio), kan SCTP ikke være sat op i den originale SDP. Brug `onnegotiationneeded` til automatisk renegotiering — men undgå dobbelt offer ved at sætte et `pendingOffer`-flag inden eksplicit `createOffer()`:

```javascript
let pendingOffer = false;

function createPeerConnection() {
  pc = new RTCPeerConnection({ iceServers });

  pc.onnegotiationneeded = async () => {
    if (pendingOffer || pc.signalingState !== 'stable') return;
    try {
      pendingOffer = true;
      const offer = await pc.createOffer();
      if (pc.signalingState !== 'stable') return; // check igen efter await
      await pc.setLocalDescription(offer);
      sendSignal({ type: 'offer', sdp: pc.localDescription });
    } finally {
      pendingOffer = false;
    }
  };

  pc.ondatachannel = e => { /* modtag fil-transfer DataChannel */ };
}

// Sæt flag inden addTrack() så onnegotiationneeded ikke løber i kappestrid med explicit createOffer()
async function startScreenShare() {
  pendingOffer = true;
  pc.addTrack(...);
  try {
    const offer = await pc.createOffer();
    // ...
  } finally {
    pendingOffer = false;
  }
}
```

`onnegotiationneeded` fyrer synkront ved `addTrack()` / `createDataChannel()`, men handleren kører asynkront — uden `pendingOffer`-guard kan begge paths kalde `createOffer()` næsten samtidig.

## Automatisk genforsøg ved WebRTC-forbindelsesfejl

`failed`-tilstand er permanent — browser genetablerer ikke på egen hånd. `disconnected` er transient og kan self-recovere. Håndtér begge i `onconnectionstatechange`:

```javascript
pc.onconnectionstatechange = () => {
  const state = pc.connectionState;
  if (state === 'disconnected' || state === 'failed') {
    // ryd op i UI ...
    if (sharing) {
      const thisPc = pc;
      const delay = state === 'failed' ? 2000 : 10000;
      setTimeout(() => {
        if (pc === thisPc && sharing && pc.connectionState !== 'connected') {
          reinitiateOffer();
        }
      }, delay);
    }
  }
};
```

`pc === thisPc`-tjekket sikrer at timeoutet ikke kører hvis PC'en allerede er erstattet af en manuel genoprettelse. Hvis WS aldrig gik ned (og ingen ny `join`-besked sendes), er dette den eneste måde forbindelsen genetableres på.

## Opkald: send offer efter accept, ikke med det samme

Caller sender ikke WebRTC offer ved `call-invite` — først når callee sender `call-accept`. Undgår ICE-gathering og TURN-allokering for opkald der afvises.

Signal-flow:
```
call-invite → call-accept/call-reject → offer → answer → ICE-kandidater → call-end
```

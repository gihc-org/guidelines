# Web frontend — generelle regler

## CSS: brug aldrig `style.display = ''` til at vise skjulte elementer

Brug altid en eksplicit værd (`'block'`, `'inline-block'`, `'flex'` osv.) afhængigt af elementets layout-kontekst.

`element.style.display = ''` fjerner kun den inline-stil — CSS-reglen `display: none` vinder stadig, og elementet forbliver usynligt.

## Audio/Video autoplay

Kald altid `.play()` eksplicit og håndtér den returnerede Promise efter at have sat `srcObject`:

```javascript
audio.srcObject = stream;
audio.play().catch(() => {});
```

Browsers blokerer autoplay hvis der er gået tid siden brugerens seneste interaktion.

## `e.streams[0]` frem for manuel MediaStream

Brug `e.streams[0]` direkte i `ontrack` i stedet for at bygge en ny `MediaStream` og tilføje tracks manuelt — det er mere pålideligt og understøttet af alle browsere.

# Claude Code — hooks og opsætning

## Referat-påmindelse ved sessionslut

Projekter der bruger `referater/`-mappen bør have et Stop-hook der minder
om at lave et referat hvis ingen er oprettet i den aktuelle session.

Hookene sættes op i `.claude/settings.local.json` (gitignored, personlig
opsætning pr. projekt):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "touch /tmp/claude-session-start-<projektnavn>"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -d referater ] && ! find referater -name '*.md' -newer /tmp/claude-session-start-<projektnavn> 2>/dev/null | grep -q .; then printf '{\"systemMessage\":\"Ingen referat endnu \\u2014 \\u00f8nsker du et referat af sessionen?\"}'; fi"
          }
        ]
      }
    ]
  }
}
```

Erstat `<projektnavn>` med et unikt navn (f.eks. `sso`, `notes`) så
markørfilen ikke kolliderer mellem projekter.

**Hvordan det virker:**
- `SessionStart` sætter et tidsstempel i `/tmp/` når sessionen starter
- `Stop` tjekker om der findes en `.md`-fil i `referater/` der er nyere
  end tidsstemplet — én pr. session, ikke én pr. dag
- Beskeden forsvinder automatisk når referatet er skrevet

**Tilpas til projektet:** Hvis mappen hedder noget andet end `referater/`,
opdatér begge steder i Stop-kommandoen.

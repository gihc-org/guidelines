# Vidensstyring — hvor gemmes hvad

## Baggrund

Kristian arbejder med flere AI-værktøjer (Claude Code, Aider, DeepSeek m.fl.) og
ønsker en vidensbase der fungerer uafhængigt af det specifikke værktøj. Viden der
gemmes i et værktøjs proprietære hukommelse (f.eks. Claude Codes memory-funktion)
er ikke tilgængelig for andre værktøjer og skaber siloer.

Løsningen er at gemme al projektviden som almindelige `.md`-filer i mappestrukturen,
så enhver agent — og ethvert menneske — kan læse dem.

## Hierarki: hvad gemmes hvor

| Indhold | Destination |
|---------|-------------|
| Best practices og mønstre der gælder på tværs af projekter | `~/projects/guidelines/` |
| Arkitektoniske beslutninger og valg af teknologi | `~/projects/adrs/` |
| Projektspecifik kontekst der ikke passer andre steder | `./kontekst/` |
| Sammendrag af arbejdssessioner | `./referater/` |
| Brugerprofil (navn, kommunikationsstil, præferencer) | AI-værktøjets egen memory |

Beslut destination med denne rækkefølge:

1. **Kan det generaliseres og bruges i andre projekter?** → `~/projects/guidelines/`
2. **Er det et arkitektonisk valg eller teknologibeslutning?** → `~/projects/adrs/`
3. **Er det et sammendrag af en arbejdssession?** → `./referater/`
4. **Er det projektspecifik kontekst?** → `./kontekst/`
5. **Er det udelukkende om brugeren som person?** → AI-værktøjets memory

Projektspecifik kontekst gemmes **ikke** i AI-værktøjets memory, selv om
værktøjet tilbyder det.

## Guidelines (`~/projects/guidelines/`)

Generelle regler og mønstre der gælder på tværs af projekter. Skrives som
selvstændige `.md`-filer med et beskrivende navn (f.eks. `security.md`,
`web-frontend.md`).

Tilføjes til et projekts `AGENTS.md` via `@`-reference:

```markdown
@~/projects/guidelines/security.md
```

## ADRs (`~/projects/adrs/`)

Architecture Decision Records — dokumenterer *hvorfor* et valg blev truffet,
ikke kun *hvad* der blev valgt. Nummereres fortløbende (`0042-navn.md`) og
linkes fra projektets `AGENTS.md`.

## Projektspecifik kontekst (`./kontekst/`)

Viden der er specifik for ét projekt og ikke kan generaliseres: arkitekturoversigt,
vigtige quirks, endpointliste, datamodel-detaljer m.m.

Skrives som `.md`-filer med beskrivende navne, f.eks. `arkitektur.md`.
Opdateres løbende efterhånden som projektet udvikler sig.

## Session-referater (`./referater/`)

Et kort sammendrag skrives ved afslutningen af hver arbejdssession og gemmes
som `./referater/YYYY-MM-DD.md` (eller med et kort emne-suffiks ved flere
sessioner samme dag: `YYYY-MM-DD-auth.md`).

Formålet er at give næste sessions AI og menneske et fælles udgangspunkt uden
at skulle genlæse hele git-historikken.

Et referat bør indeholde:
- Hvad blev lavet og committet
- Beslutninger der blev truffet (og kort hvorfor)
- Kendte uafklarede spørgsmål eller næste skridt
- Eventuelle gotchas der dukkede op undervejs

## Hvad AI-memory må bruges til

Kun oplysninger om brugeren *som person* der ikke hører hjemme i et projektrepo:
- Navn og foretrukket kommunikationssprog
- Kommunikationsstil og præferencer for svar
- Generelle arbejdspræferencer på tværs af alle projekter

Al projektviden — selv "midlertidig" kontekst — gemmes i filsystemet, ikke i memory.

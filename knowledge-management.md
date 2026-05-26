# Vidensstyring — hvor gemmes hvad

> **AI-agent? Læs først dette afsnit.**
> Inden du genererer eller refererer projektviden: beslut hvor den hører
> hjemme ved at gennemgå tjeklisten nedenfor. Sig højt hvilken destination
> du har valgt og hvorfor — det giver brugeren chancen for at korrigere før
> viden ender det forkerte sted.

## Tjekliste: hvor hører viden hjemme

Gå listen i rækkefølge. Det første der matcher er destinationen.

1. **Sammendrag af en arbejdssession** → `./referater/YYYY-MM-DD.md`
2. **Arkitekturvalg eller teknologibeslutning** → ny ADR i
   `~/projects/adrs/NNNN-navn.md`, linket fra projektets `AGENTS.md`
3. **Mønster der gælder på tværs af projekter** → ny `.md`-fil i
   `~/projects/guidelines/`, `@`-referer fra projektets `AGENTS.md`
4. **Projektspecifik kontekst** (arkitektur, quirks, datamodel) →
   `./kontekst/`
5. **Udelukkende om brugeren som person** (navn, kommunikationsstil,
   generelle præferencer) → AI-værktøjets memory

## Hvad må IKKE gemmes i AI-værktøjets memory

- Projektkontekst (selv "midlertidig")
- Arkitekturbeslutninger
- Tekniske mønstre eller kode-konventioner
- Sessionsspecifik state

AI-værktøjets memory er værktøjsspecifik og skaber siloer mellem Claude
Code, Aider, DeepSeek m.fl. Al projektviden gemmes i filsystemet som
almindelige `.md`-filer så enhver agent — og ethvert menneske — kan læse
den.

## Detaljer

### Guidelines (`~/projects/guidelines/`)

Generelle regler og mønstre der gælder på tværs af projekter. Skrives som
selvstændige `.md`-filer med et beskrivende navn (f.eks. `security.md`,
`web-frontend.md`).

Tilføjes til et projekts `AGENTS.md` via `@`-reference:

```markdown
@~/projects/guidelines/security.md
```

### ADRs (`~/projects/adrs/`)

Architecture Decision Records — dokumenterer *hvorfor* et valg blev truffet,
ikke kun *hvad* der blev valgt. Nummereres fortløbende (`0042-navn.md`) og
linkes fra projektets `AGENTS.md`.

### Projektspecifik kontekst (`./kontekst/`)

Viden der er specifik for ét projekt og ikke kan generaliseres:
arkitekturoversigt, vigtige quirks, endpointliste, datamodel-detaljer m.m.

Skrives som `.md`-filer med beskrivende navne, f.eks. `arkitektur.md`.
Opdateres løbende efterhånden som projektet udvikler sig.

### Session-referater (`./referater/`)

Et kort sammendrag skrives ved afslutningen af hver arbejdssession og
gemmes som `./referater/YYYY-MM-DD.md` (eller med et kort emne-suffiks ved
flere sessioner samme dag: `YYYY-MM-DD-auth.md`).

Formålet er at give næste sessions AI og menneske et fælles udgangspunkt
uden at skulle genlæse hele git-historikken.

Et referat bør indeholde:

- Hvad blev lavet og committet (med commit-refs)
- Beslutninger der blev truffet (og kort hvorfor)
- Kendte uafklarede spørgsmål eller næste skridt
- Eventuelle gotchas der dukkede op undervejs

## Baggrund

Kristian arbejder med flere AI-værktøjer (Claude Code, Aider, DeepSeek
m.fl.) og ønsker en vidensbase der fungerer uafhængigt af det specifikke
værktøj. Viden gemt i et værktøjs proprietære hukommelse er ikke
tilgængelig for andre værktøjer og skaber siloer.

Løsningen er at gemme al projektviden som almindelige `.md`-filer i
mappestrukturen, så enhver agent — og ethvert menneske — kan læse dem.

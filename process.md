# Proces — arbejdsflow og kvalitetssikring

## Nye features skal i TODO før implementering

Inden en ny feature implementeres, tilføjes den til `TODO.md` i projektet med:
- En kort beskrivelse af hvad der skal laves
- Eventuelle delopgaver som checkboxes

Dette gælder også små features og forbedringer. Formålet er at sikre at intet implementeres uden at have været overvejet og synliggjort.

**Undtagelser:** Bugfixes og hotfixes der løser et akut problem kan implementeres direkte — men tilføjes stadig til TODO som ✅ efterfølgende så historikken er komplet.

## Vurdér ADR og guidelines efter hver implementering

Når en feature eller delopgave er implementeret og committed, vurderer AI *på eget initiativ* om der bør skrives:

**En ny ADR** hvis implementeringen indeholder:
- Et ikke-oplagt teknologivalg (framework, protokol, dataformat)
- En arkitektonisk beslutning der påvirker fremtidige features
- Et valg der blev truffet efter afvejning af alternativer

**En ny eller opdateret guideline** hvis implementeringen afslørede:
- En generel fejl eller gotcha der kan ramme andre projekter
- Et mønster der bør genbruges på tværs af projekter
- En best practice der ikke allerede er dokumenteret

Vurderingen behøver ikke resultere i handling — men den skal altid foretages og konklusionen kommunikeres kort ("ingen ny ADR nødvendig her" er et gyldigt svar).

## Skriv et referat ved afslutning af sessionen

Når en arbejdssession afsluttes, skrives et kort referat i `./referater/` med filnavnet `YYYY-MM-DD-HH-MM.md` (24-timers ur).

Referatet skal indeholde:
- Hvad blev lavet og committet
- Beslutninger der blev truffet og kort hvorfor
- Kendte uafklarede spørgsmål eller næste skridt
- Eventuelle gotchas der dukkede op undervejs

Formålet er at give næste sessions AI og menneske et fælles udgangspunkt uden at skulle genlæse hele git-historikken. Se også [knowledge-management.md](knowledge-management.md).

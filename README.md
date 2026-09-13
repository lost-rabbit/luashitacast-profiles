# LuAshitaCast profiles

Small, self-contained LuAshitaCast profiles for HorizonXI. Each one is a
single file: copy it into your profile folder under the job name and it works.

## Staves.lua

Elemental staves for any mage job.

- When you cast, the staff of the spell's element goes into your main hand for
  the cast. Fire, Ice, Wind, Earth, Thunder, Water, Light (Cure, Dia, Banish)
  and Dark (Bio, Drain, Aspir, Sleep, Blind). Every tier, the -ga and -ra
  lines, Ancient Magic, summons and ninjutsu, since it reads the element the
  game stamps on the spell.
- The HQ staff (Vulcan's, Aquilo's, Auster's, Terra's, Jupiter's, Neptune's,
  Apollo's, Pluto's) is used whenever you own it. It checks your bags, so a
  new staff needs no edit.
- When you sit down to rest, the Dark Staff or Pluto's goes on for the MP
  refresh.
- Nothing else is touched: every armour slot stays as you have it.

### Install

1. In game, `/addon load luashitacast` once. It creates your profile folder:
   `Game\config\addons\luashitacast\<YourName>_<Id>\`
2. Copy `Staves.lua` into that folder once per job you want it on, named
   after the job: `WHM.lua`, `BLM.lua`, `RDM.lua`, `SMN.lua`, `BRD.lua`.
3. Change job, or type `/lac load`.

### Settings

Two lines at the top of the file:

- `IDLE_MAIN`: your everyday weapon, put back when you stand up or finish
  casting. Leave blank and the last staff simply stays in hand.
- `USE_HQ`: set to `false` to always use the plain staff.

A main-hand swap resets TP, which is nothing for a mage, but if you melee on
RDM you may not want this profile on that job.

Creation assisted by ADA.

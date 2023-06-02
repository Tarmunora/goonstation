# mutantrace customization, mild refactor, etc

## Goals:
- Add customization options (a la human hair) for roundstart mutantraces:
  - use standard customization_1/2/3 slots for everyone
  - deprecate special_styles, special_hair, and mutantrace_detail

- Make "human" a proper mutantrace, rather than just being `null`
  - allow all `human` mobs access to mutant-race specific vars and methods
  - less special-casing for mutant-race specific stuff

## current impl details:

- Add `var/list/valid_races` to `datum/customization_style`
  - Issue: whitelist-based system has classic whitelist problems
    - add optional blacklist support? Unsure
    - Use some kind of category system?
- Pass mutantrace (name) to style-picking procs

- Maybe: lock certain customization styles to layer 1/2/3-only - e.g.: enforce only 1 horns option for cows etc

## TODO:
- Implement for style cycling in prefs
- Clear styles when swapping mutantraces in prefs
- Lizard skin color stuff
  - Probably want to use skin color customization for lizard skin color instead of one of the detail slots
- Unknown issues abound 😭

# SynthDefs

Place custom SuperCollider SynthDef files (`.scd`) here. The root `startup.scd` loads every `.scd` file in this directory before starting SuperDirt.

## `strudelSine`

`strudel-sine.scd` ports Strudel/SuperDough's stock `sine` oscillator, FM
scaling, fixed 0.3 voice level, and linear envelope to SuperDirt.

```haskell
d1 $ note "f4 ~ c4 d4 . f3 g4 ~ ~ . f4 d3 g4 c4"
  # s "strudelSine"
  # fm 0.06
  # sineAttack 0.3
  # sineDecay 0.8
  # sineRelease 0.9
  # legato 2
  # gain 0.06
```

The `sine*` names deliberately avoid Tidal's standard `attack` and `release`
controls: those activate SuperDirt's post-synth envelope and would apply the
envelope twice. `sineRelease` corresponds to Strudel's abbreviated `.rel(...)`.

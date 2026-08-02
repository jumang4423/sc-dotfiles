# Effects

Place custom SuperCollider or SuperDirt effect files (`.scd`) here. Document non-obvious controls and their expected ranges in each file.

## `tiny-smear.scd`

A per-event micro-convolution reverb. Dense, decorrelated stereo noise impulse responses are processed with partitioned convolution around only the events carrying `tinySmear`. It contains no low-pass, high-pass, or tone-shaping filter.

`tinySmear` is the only control. Supplying `0` selects the smallest 15 ms IR; `1` selects the largest 200 ms IR. Omitting `tinySmear` bypasses the effect. Sixteen duration levels are available between those endpoints.

Whenever the effect is active, its mix remains fixed at dry gain 0.40 plus wet gain 1.0. The internal decay follows the IR duration at 75% of its length.

TidalCycles example:

```haskell
d1 $ sound "bd sd*2"
  # tinySmear 0.65
```

Omit `tinySmear` to leave an event dry. Increasing its value changes room duration, not the dry/wet mix.

Because this is a Dirt module rather than a global orbit effect, it is instantiated only for an event where `tinySmear` is greater than zero. Other simultaneous events remain dry unless they also carry the parameter.

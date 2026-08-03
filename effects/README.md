# Effects

Place custom SuperCollider or SuperDirt effect files (`.scd`) here. Document non-obvious controls and their expected ranges in each file.

## `tiny-smear.scd`

A per-event micro-convolution reverb. Dense, decorrelated stereo noise impulse responses are processed with partitioned convolution around only the events carrying `tinySmear`. It contains no low-pass, high-pass, or tone-shaping filter.

The IR begins with a short density fade-in so broadband transients such as snares produce a room bloom rather than a distinct delayed second hit. Effect nodes use the event's normal lifetime and do not remain alive to process later events.

`tinySmear` is the only control. Supplying `0` selects the smallest 15 ms IR; `1` selects the largest 200 ms IR. Omitting `tinySmear` bypasses the effect. Sixteen duration levels are available between those endpoints.

Whenever the effect is active, its mix remains fixed at dry gain 0.40 plus wet gain 1.0. The internal decay follows the IR duration at 75% of its length.

TidalCycles example:

```haskell
d1 $ sound "bd sd*2"
  # tinySmear 0.65
```

Omit `tinySmear` to leave an event dry. Increasing its value changes room duration, not the dry/wet mix.

Because this is a Dirt module rather than a global orbit effect, it is instantiated only for an event where `tinySmear` is greater than zero. Other simultaneous events remain dry unless they also carry the parameter.

## `disperser.scd`

A per-event phase-rotation effect made from cascaded biquad all-pass filters. It changes transient shape and group delay while keeping the magnitude response approximately flat.

`disperser` controls the phase-rotation stage count. `0` bypasses the effect. Values above zero select progressively heavier cascades:

| Value | Stages |
| ---: | ---: |
| 0.01 | 8 |
| 0.17 | 16 |
| 0.33 | 32 |
| 0.50 | 64 |
| 0.67 | 128 |
| 0.83 | 256 |
| 1.00 | 512 |

Additional control:

| Parameter | Range | Default | Meaning |
| --- | ---: | ---: | --- |
| `disperserFreq` | 20–20000 Hz | 200 | Center frequency of the phase rotation |

Q is fixed internally at `0.5`. The output is wet 100%, dry 0%: the phase-rotated signal replaces the dry signal instead of being mixed with it. These controls do not change musical pitch; use Tidal's normal pitch controls such as `note`, `n`, or `speed` for that.

```haskell
d1 $ sound "bd*2 sn"
  # disperser 0.67
  # disperserFreq 350
```

The concept is inspired by Diopser by Robbert van der Helm. This SuperCollider implementation is independently written from the underlying cascaded-all-pass DSP principle; no JUCE source code is included.

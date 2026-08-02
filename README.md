# sc-dotfiles

Personal TidalCycles and SuperCollider environment.

This repository contains my shared live-coding and sound-design setup:

- TidalCycles configuration
- SuperCollider startup configuration
- custom SynthDefs
- custom effects
- samples
- C++ UGens
- TidalCycles files

The repository should remain small, direct, and easy to understand.

## Structure

```text
sc-dotfiles/
├── README.md
├── BootTidal.hs
├── startup.scd
├── synthdefs/
├── effects/
├── samples/
├── ugens/
└── sets/
```

## `BootTidal.hs`

TidalCycles boot configuration.

It may contain:

- Tidal stream configuration
- custom control parameters
- reusable pattern functions
- OSC targets
- MIDI targets

Individual tracks and live-coding sessions belong in `sets/`.

## `startup.scd`

Main SuperCollider entry point.

It is responsible for:

- configuring and booting the SuperCollider server
- starting SuperDirt
- loading the standard Dirt-Samples banks
- loading samples from `samples/`
- loading SynthDefs from `synthdefs/`
- loading effects from `effects/`
- waiting for asynchronous operations when necessary
- printing a ready message when startup is complete

Paths inside the repository should be resolved relative to `startup.scd`.

A machine’s regular SuperCollider startup file can load this file:

```supercollider
"~/path/to/sc-dotfiles/startup.scd"
    .standardizePath
    .load;
```

## `synthdefs/`

Custom SuperCollider SynthDefs.

```text
synthdefs/
├── fm.scd
├── granular.scd
├── physical-modeling.scd
└── sampler.scd
```

Each file may contain one instrument or a closely related group of instruments.

SynthDefs used through SuperDirt should support the necessary event parameters and output routing.

Prefer musically meaningful controls such as:

```text
brightness
body
pressure
roughness
instability
material
```

## `effects/`

Custom SuperCollider and SuperDirt effects.

```text
effects/
├── distortion.scd
├── spectral-blur.scd
└── spectral-delay.scd
```

Effect files should describe their parameters and expected value ranges when these are not obvious.

Matching control parameters may also need to be defined in `BootTidal.hs`.

Included effects:

- `tiny-smear.scd`: filter-free per-event stereo PartConv reverb controlled only by `tinySmear`

## `samples/`

Samples loaded by SuperDirt.

Each immediate subdirectory is treated as a sample bank.

```text
samples/
├── metal/
│   ├── hit.wav
│   └── scrape.wav
├── texture/
│   └── noise.wav
└── voice/
    ├── a.wav
    └── b.wav
```

Example:

```haskell
d1 $ sound "metal:0 voice:1 texture:0"
```

Only store samples that are appropriate to keep in this repository.

## `ugens/`

Source code for custom SuperCollider C++ UGens.

Each UGen should have its own directory.

```text
ugens/
└── MySpectralEngine/
    ├── CMakeLists.txt
    ├── plugins/
    ├── classes/
    ├── help/
    └── README.md
```

Source files belong in the repository. Generated build output does not.

A custom UGen may be used when the required DSP is unavailable, impractical, or too slow to implement with existing SuperCollider UGens.

## `sets/`

TidalCycles files.

```text
sets/
├── test.tidal
├── 2026-08-02.tidal
├── weird-rhythm.tidal
├── abc.tidal
└── untitled.tidal
```

No directory structure or naming convention is required.

## Design

TidalCycles handles:

- timing
- sequencing
- pattern transformation
- repetition
- high-level parameter control

SuperCollider and custom UGens handle:

- synthesis
- sample playback
- signal processing
- effects
- audio routing

Prefer extending the system with custom SynthDefs, effects, Tidal parameters, and UGens instead of modifying SuperDirt itself.

Keep `BootTidal.hs` and `startup.scd` as the two main entry points.

## Setup

Configure the VS Code TidalCycles extension to use:

```text
/path/to/sc-dotfiles/BootTidal.hs
```

Configure SuperCollider to load:

```text
/path/to/sc-dotfiles/startup.scd
```

The external loader path may be machine-specific. Code inside this repository should otherwise remain portable.

## Workflow

The normal performance workflow remains VS Code plus the SuperCollider application. Command-line support is also available for repeatable setup and automated checks:

```text
make check
make start
make status
make logs
make stop
```

Use `make check` after changing `startup.scd`, SynthDefs, effects, or samples. It boots the complete SuperCollider environment, waits for the ready message, and shuts it down again.

The repository's VS Code workspace setting clears any global custom boot-file override. The TidalCycles extension therefore discovers the local `BootTidal.hs` when this folder is opened.

Use `make start` when a visible SuperCollider IDE is not needed. It runs SuperCollider and SuperDirt in the background and writes output to `.run/supercollider.log`. Use `make stop` to shut down only the process started by this repository.

During a TidalCycles session, evaluate `hush` to stop all active patterns without shutting down SuperCollider.

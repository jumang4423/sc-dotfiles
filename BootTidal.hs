:set -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Context
import System.IO (hSetEncoding, stdout, utf8)

hSetEncoding stdout utf8

tidal <- startTidal (superdirtTarget { oLatency = 0.1 }) (defaultConfig { cFrameTimespan = 1 / 20 })

let p = streamReplace tidal
    d1 = p 1
    d2 = p 2
    d3 = p 3
    d4 = p 4
    d5 = p 5
    d6 = p 6
    d7 = p 7
    d8 = p 8
    d9 = p 9
    d10 = p 10
    d11 = p 11
    d12 = p 12
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16
    hush = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    fm = pF "fm"
    sineAttack = pF "sineAttack"
    sineDecay = pF "sineDecay"
    sineRelease = pF "sineRelease"
    tinySmear = pF "tinySmear"
    disperser = pF "disperser"
    disperserFreq = pF "disperserFreq"

:set prompt "tidal> "
:set prompt-cont ""

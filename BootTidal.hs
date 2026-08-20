:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Boot
import System.IO (hSetEncoding, stdout, utf8)

hSetEncoding stdout utf8

default (Rational, Integer, Double, Pattern String)

tidalInst <- mkTidalWith
  [(superdirtTarget { oLatency = 0.1 }, [superdirtShape])]
  (defaultConfig { cFrameTimespan = 1 / 20 })

instance Tidally where
  tidal = tidalInst

-- custom SuperDirt parameters
let fm = pF "fm"
    sineAttack = pF "sineAttack"
    sineDecay = pF "sineDecay"
    sineRelease = pF "sineRelease"
    tinySmear = pF "tinySmear"
    disperser = pF "disperser"
    disperserFreq = pF "disperserFreq"

:set prompt "tidal> "
:set prompt-cont ""
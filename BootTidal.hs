:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Boot
import System.IO (hSetEncoding, stdout, utf8)
import qualified Data.Map as TMMap
import Control.Concurrent.MVar (readMVar)
import Control.Monad (filterM)

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

-- text.management: print d-numbers holding sounding patterns (e.g. "TM-ACTIVE 1 3")
-- (no standalone signature: ghci rejects a signature sent as its own line)
tmActiveDs = do
  pmap <- readMVar (sPMapMV tidal)
  let solos = [n | (n, ps) <- TMMap.toList pmap, psSolo ps]
  let cands = if null solos then map show ([1..16] :: [Int]) else solos
  active <- filterM (tmActiveN pmap) cands
  putStrLn ("TM-ACTIVE" ++ concatMap (" " ++) active)
  where
    tmActiveN pmap n = case TMMap.lookup n pmap of
      Nothing -> return False
      Just ps -> return (not (psMute ps) && not (null (queryArc (psPattern ps) (Arc 0 8))))

:set prompt "tidal> "
:set prompt-cont ""
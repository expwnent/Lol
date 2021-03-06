{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE NoImplicitPrelude    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE UndecidableInstances #-}

module TensorBenches (tensorBenches) where

import Apply.Cyc
import Benchmarks
import Params.LolParams

import Control.Applicative
import Control.Monad.Random

import Crypto.Lol.Prelude
import Crypto.Lol.Cyclotomic.Tensor
import Crypto.Lol.Types
import Crypto.Random.DRBG

tensorBenches :: IO Benchmark
tensorBenches = benchGroup "Tensor" [
  benchGroup "unzipPow"    $ [hideArgs bench_unzip testParam],
  benchGroup "unzipDec"    $ [hideArgs bench_unzip testParam],
  benchGroup "unzipCRT"    $ [hideArgs bench_unzip testParam],
  benchGroup "zipWith (*)" $ [hideArgs bench_mul testParam],
  benchGroup "crt"         $ [hideArgs bench_crt testParam],
  benchGroup "crtInv"      $ [hideArgs bench_crtInv testParam],
  benchGroup "l"           $ [hideArgs bench_l testParam],
  benchGroup "lInv"        $ [hideArgs bench_lInv testParam],
  benchGroup "*g Pow"      $ [hideArgs bench_mulgPow testParam],
  benchGroup "*g Dec"      $ [hideArgs bench_mulgDec testParam],
  benchGroup "*g CRT"      $ [hideArgs bench_mulgCRT testParam],
  benchGroup "divg Pow"    $ [hideArgs bench_divgPow testParam],
  benchGroup "divg Dec"    $ [hideArgs bench_divgDec testParam],
  benchGroup "divg CRT"    $ [hideArgs bench_divgCRT testParam],
  benchGroup "lift"        $ [hideArgs bench_liftPow testParam],
  benchGroup "error"       $ [hideArgs (bench_errRounded 0.1) testParam'],
  benchGroup "twacePow"    $ [hideArgs bench_twacePow twoIdxParam],
  benchGroup "twaceDec"    $ [hideArgs bench_twacePow twoIdxParam], -- yes, twacePow is correct here. It's the same function!
  benchGroup "twaceCRT"    $ [hideArgs bench_twaceCRT twoIdxParam],
  benchGroup "embedPow"    $ [hideArgs bench_embedPow twoIdxParam],
  benchGroup "embedDec"    $ [hideArgs bench_embedDec twoIdxParam],
  benchGroup "embedCRT"    $ [hideArgs bench_embedCRT twoIdxParam]
  ]

bench_unzip :: (UnzipCtx t m r) => t m (r,r) -> Bench '(t,m,r)
bench_unzip = bench unzipT

-- no CRT conversion, just coefficient-wise multiplication
bench_mul :: (BasicCtx t m r) => t m r -> t m r -> Bench '(t,m,r)
bench_mul a = bench (zipWithT (*) a)

-- convert input from Pow basis to CRT basis
bench_crt :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_crt = bench (fromJust' "TensorBenches.bench_crt" crt)

-- convert input from CRT basis to Pow basis
bench_crtInv :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_crtInv = bench (fromJust' "TensorBenches.bench_crtInv" crtInv)

-- convert input from Dec basis to Pow basis
bench_l :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_l = bench l

-- convert input from Dec basis to Pow basis
bench_lInv :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_lInv = bench lInv

-- lift an element in the Pow basis
bench_liftPow :: forall t m r . (LiftCtx t m r) => t m r -> Bench '(t,m,r)
bench_liftPow = bench (fmapT lift)

-- multiply by g when input is in Pow basis
bench_mulgPow :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_mulgPow = bench mulGPow

-- multiply by g when input is in Dec basis
bench_mulgDec :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_mulgDec = bench mulGDec

-- multiply by g when input is in CRT basis
bench_mulgCRT :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_mulgCRT = bench (fromJust' "TensorBenches.bench_mulgCRT" mulGCRT)

-- divide by g when input is in Pow basis
bench_divgPow :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_divgPow x =
  let y = mulGPow x
  in bench divGPow y

-- divide by g when input is in Dec basis
bench_divgDec :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_divgDec x =
  let y = mulGDec x
  in bench divGDec y

-- divide by g when input is in CRT basis
bench_divgCRT :: (BasicCtx t m r) => t m r -> Bench '(t,m,r)
bench_divgCRT = bench (fromJust' "TensorBenches.bench_divgCRT" divGCRT)

-- generate a rounded error term
bench_errRounded :: forall t m r gen . (ErrorCtx t m r gen)
  => Double -> Bench '(t,m,r,gen)
bench_errRounded v = benchIO $ do
  gen <- newGenIO
  return $ evalRand
    (fmapT (roundMult one) <$>
      (tGaussianDec v :: Rand (CryptoRand gen) (t m Double)) :: Rand (CryptoRand gen) (t m (LiftOf r))) gen

bench_twacePow :: forall t m m' r . (TwoIdxCtx t m m' r)
  => t m' r -> Bench '(t,m,m',r)
bench_twacePow = bench (twacePowDec :: t m' r -> t m r)

bench_twaceCRT :: forall t m m' r . (TwoIdxCtx t m m' r)
  => t m' r -> Bench '(t,m,m',r)
bench_twaceCRT = bench (fromJust' "TensorBenches.bench_twaceCRT" twaceCRT :: t m' r -> t m r)

bench_embedPow :: forall t m m' r . (TwoIdxCtx t m m' r)
  => t m r -> Bench '(t,m,m',r)
bench_embedPow = bench (embedPow :: t m r -> t m' r)

bench_embedDec :: forall t m m' r . (TwoIdxCtx t m m' r)
  => t m r -> Bench '(t,m,m',r)
bench_embedDec = bench (embedDec :: t m r -> t m' r)

bench_embedCRT :: forall t m m' r . (TwoIdxCtx t m m' r)
  => t m r -> Bench '(t,m,m',r)
bench_embedCRT = bench (fromJust' "TensorBenches.bench_embedCRT" embedCRT :: t m r -> t m' r)

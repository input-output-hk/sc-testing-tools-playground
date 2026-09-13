{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ViewPatterns #-}

module Main where

import Cardano.Api qualified as C
import Cardano.Api.Ledger qualified as Ledger
import Cardano.Ledger.Plutus.ExUnits (ExUnits (exUnitsMem))
import Control.Lens ((%~), (&))
import Convex.NodeParams (NodeParams (..))
import Convex.NodeParams qualified as NP
import Convex.Tasty.Streaming (defaultMainStreaming)
import Convex.TestingInterface (Options (..), RunOptions (..), defaultOptions, defaultRunOptions)
import Data.Functor.Identity (Identity)
import Test.Tasty (TestTree, testGroup)

import Auction.Spec.Prop qualified as Auction
import Escrow.Spec.Prop qualified as Escrow
import MultiPlayerPingPong.Spec.Prop qualified as MultiPlayerPingPong
import RewardWithdrawal.Spec.Prop qualified as RewardWithdrawal
import Vesting.Spec.Prop qualified as Vesting

modifyVestingMemoryLimit :: Options C.ConwayEra -> Options C.ConwayEra
modifyVestingMemoryLimit opts =
  let
    params0 = params opts
    C.LedgerProtocolParameters (Ledger.PParams ppHkd) = npProtocolParameters params0
    ppHkd' =
      ppHkd
        & NP.hkdMaxTxExUnitsL @_ @Identity
          %~ (\ex -> ex{exUnitsMem = 30_000_000})
   in
    opts
      { params =
          params0
            { npProtocolParameters =
                C.LedgerProtocolParameters (Ledger.PParams ppHkd')
            }
      }

main :: IO ()
main = defaultMainStreaming tests

tests :: TestTree
tests =
  let
    vestingOpts = modifyVestingMemoryLimit defaultOptions
    vestingRunOpts = defaultRunOptions{mcOptions = vestingOpts}
   in
    testGroup
      "Normal Examples (PBT)"
      [ Auction.propBasedTests
      , Escrow.propBasedTests
      , MultiPlayerPingPong.propBasedTests
      , RewardWithdrawal.propBasedTests defaultRunOptions
      , Vesting.propBasedTests vestingRunOpts
      ]

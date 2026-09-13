{-# LANGUAGE OverloadedStrings #-}

module Main where

import AuctionFlipped.Spec.Attacks (attackTests)
import AuctionFlipped.Spec.Prop (propBasedTests)
import AuctionFlipped.Spec.Unit (unitTests)
import Convex.Tasty.Streaming (defaultMainStreaming)
import Test.Tasty (TestTree, testGroup)

--------------------------------------------------------------------------------
-- Main Test Entry Point
--------------------------------------------------------------------------------

main :: IO ()
main = defaultMainStreaming tests

tests :: TestTree
tests =
  testGroup
    "auction tests"
    [ unitTests
    , attackTests
    , propBasedTests
    ]

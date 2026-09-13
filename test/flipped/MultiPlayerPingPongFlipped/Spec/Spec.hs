{-# LANGUAGE OverloadedStrings #-}

module Main where

import Convex.Tasty.Streaming (defaultMainStreaming)
import MultiPlayerPingPongFlipped.Spec.Prop (propBasedTests)
import MultiPlayerPingPongFlipped.Spec.Unit (unitTests)
import Test.Tasty (TestTree, testGroup)

--------------------------------------------------------------------------------
-- Main Test Entry Point
--------------------------------------------------------------------------------

main :: IO ()
main = defaultMainStreaming tests

tests :: TestTree
tests =
  testGroup
    "multi-player ping-pong tests"
    [ unitTests
    , propBasedTests
    ]

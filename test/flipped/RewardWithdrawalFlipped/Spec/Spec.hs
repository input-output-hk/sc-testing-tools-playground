{-# LANGUAGE ImportQualifiedPost #-}

import Convex.Tasty.Streaming (defaultMainStreaming)
import Convex.TestingInterface (RunOptions, defaultRunOptions)
import RewardWithdrawalFlipped.Spec.Prop qualified
import RewardWithdrawalFlipped.Spec.Unit qualified
import Test.Tasty (TestTree, testGroup)

main :: IO ()
main = defaultMainStreaming (tests defaultRunOptions)

tests :: RunOptions -> TestTree
tests runOpts =
  testGroup
    "reward withdrawal tests"
    [ RewardWithdrawalFlipped.Spec.Unit.unitTests
    , RewardWithdrawalFlipped.Spec.Prop.propBasedTests runOpts
    ]

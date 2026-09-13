{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}
-- 1.1.0.0 will be enabled in conway
{-# OPTIONS_GHC -fobject-code -fno-ignore-interface-pragmas -fno-omit-interface-pragmas -fplugin-opt PlutusTx.Plugin:target-version=1.1.0.0 #-}
{-# OPTIONS_GHC -fplugin-opt PlutusTx.Plugin:defer-errors #-}

-- | Scripts used for testing
module RewardWithdrawalFlipped.Scripts (
  rewardWithdrawalValidatorScript,
  RewardWithdrawalFlipped.RewardWithdrawalParams (..),
  saveRewardWithdrawalValidatorScript,
) where

import Cardano.Api qualified as C
import Convex.PlutusTx (compiledCodeToScript)
import PlutusTx (BuiltinData, CompiledCode)
import PlutusTx qualified
import PlutusTx.Prelude (BuiltinUnit)
import RewardWithdrawalFlipped.Validator qualified as RewardWithdrawalFlipped

-- | Compiling a parameterized validator for 'RewardWithdrawalFlipped.Validator.validator'
rewardWithdrawalValidatorCompiled :: RewardWithdrawalFlipped.RewardWithdrawalParams -> CompiledCode (BuiltinData -> BuiltinUnit)
rewardWithdrawalValidatorCompiled params =
  case $$(PlutusTx.compile [||RewardWithdrawalFlipped.validator||])
    `PlutusTx.applyCode` PlutusTx.liftCodeDef params of
    Left err -> error err
    Right cc -> cc

-- | Serialized validator for 'RewardWithdrawalFlipped.Validator.validator'
rewardWithdrawalValidatorScript :: RewardWithdrawalFlipped.RewardWithdrawalParams -> C.PlutusScript C.PlutusScriptV3
rewardWithdrawalValidatorScript = compiledCodeToScript . rewardWithdrawalValidatorCompiled

-- | Save the validator script to a file
saveRewardWithdrawalValidatorScript :: RewardWithdrawalFlipped.RewardWithdrawalParams -> FilePath -> IO ()
saveRewardWithdrawalValidatorScript params filePath = do
  let script = rewardWithdrawalValidatorScript params
  C.writeFileTextEnvelope (C.File filePath) Nothing script >>= \case
    Left err -> print $ C.displayError err
    Right () -> putStrLn $ "Serialized script to: " ++ filePath

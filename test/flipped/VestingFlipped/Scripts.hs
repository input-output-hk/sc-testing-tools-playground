{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}
-- 1.1.0.0 will be enabled in conway
{-# OPTIONS_GHC -fobject-code -fno-ignore-interface-pragmas -fno-omit-interface-pragmas -fplugin-opt PlutusTx.Plugin:target-version=1.1.0.0 #-}
{-# OPTIONS_GHC -fplugin-opt PlutusTx.Plugin:defer-errors #-}

-- | Scripts used for testing
module VestingFlipped.Scripts (
  vestingValidatorScript,
  VestingFlipped.VestingParams (..),
  saveVestingValidatorScript,
) where

import Cardano.Api qualified as C
import Convex.PlutusTx (compiledCodeToScript)
import PlutusTx (BuiltinData, CompiledCode)
import PlutusTx qualified
import PlutusTx.Prelude (BuiltinUnit)
import VestingFlipped.Validator qualified as VestingFlipped

-- | Compiling a parameterized validator for 'Scripts.VestingFlipped.validator'
vestingValidatorCompiled :: VestingFlipped.VestingParams -> CompiledCode (BuiltinData -> BuiltinUnit)
vestingValidatorCompiled params =
  case $$(PlutusTx.compile [||VestingFlipped.validator||])
    `PlutusTx.applyCode` PlutusTx.liftCodeDef params of
    Left err -> error err
    Right cc -> cc

-- | Serialized validator for 'Scripts.VestingFlipped.validator'
vestingValidatorScript :: VestingFlipped.VestingParams -> C.PlutusScript C.PlutusScriptV3
vestingValidatorScript = compiledCodeToScript . vestingValidatorCompiled

-- | Save the validator script to a file
saveVestingValidatorScript :: VestingFlipped.VestingParams -> FilePath -> IO ()
saveVestingValidatorScript params filePath = do
  let script = vestingValidatorScript params
  C.writeFileTextEnvelope (C.File filePath) Nothing script >>= \case
    Left err -> print $ C.displayError err
    Right () -> putStrLn $ "Serialized script to: " ++ filePath

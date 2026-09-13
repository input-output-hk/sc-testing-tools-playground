{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}
-- 1.1.0.0 will be enabled in conway
{-# OPTIONS_GHC -fobject-code -fno-ignore-interface-pragmas -fno-omit-interface-pragmas -fplugin-opt PlutusTx.Plugin:target-version=1.1.0.0 #-}
{-# OPTIONS_GHC -fplugin-opt PlutusTx.Plugin:defer-errors #-}

-- | Scripts used for testing
module EscrowFlipped.Scripts (
  escrowValidatorScript,
  EscrowFlipped.EscrowParams (..),
  saveEscrowValidatorScript,
) where

import Cardano.Api qualified as C
import Convex.PlutusTx (compiledCodeToScript)
import EscrowFlipped.Validator qualified as EscrowFlipped
import PlutusTx (BuiltinData, CompiledCode)
import PlutusTx qualified
import PlutusTx.Prelude (BuiltinUnit)

-- | Compiling a parameterized validator for 'Scripts.EscrowFlipped.validator'
escrowValidatorCompiled :: EscrowFlipped.EscrowParams -> CompiledCode (BuiltinData -> BuiltinUnit)
escrowValidatorCompiled params =
  case $$(PlutusTx.compile [||EscrowFlipped.validator||])
    `PlutusTx.applyCode` PlutusTx.liftCodeDef params of
    Left err -> error err
    Right cc -> cc

-- | Serialized validator for 'Scripts.EscrowFlipped.validator'
escrowValidatorScript :: EscrowFlipped.EscrowParams -> C.PlutusScript C.PlutusScriptV3
escrowValidatorScript = compiledCodeToScript . escrowValidatorCompiled

-- | Save the validator script to a file
saveEscrowValidatorScript :: EscrowFlipped.EscrowParams -> FilePath -> IO ()
saveEscrowValidatorScript params filePath = do
  let script = escrowValidatorScript params
  C.writeFileTextEnvelope (C.File filePath) Nothing script >>= \case
    Left err -> print $ C.displayError err
    Right () -> putStrLn $ "Serialized script to: " ++ filePath

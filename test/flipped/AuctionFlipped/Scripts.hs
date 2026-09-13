{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
-- 1.1.0.0 will be enabled in conway
{-# OPTIONS_GHC -fobject-code -fno-ignore-interface-pragmas -fno-omit-interface-pragmas -fplugin-opt PlutusTx.Plugin:target-version=1.1.0.0 #-}
{-# OPTIONS_GHC -fplugin-opt PlutusTx.Plugin:defer-errors #-}

-- | Scripts used for testing
module AuctionFlipped.Scripts (
  auctionValidatorScript,
  saveAuctionValidatorScript,
) where

import AuctionFlipped.Validator qualified as AuctionFlipped
import Cardano.Api qualified as C
import Convex.PlutusTx (compiledCodeToScript)
import PlutusTx (BuiltinData, CompiledCode)
import PlutusTx qualified
import PlutusTx.Prelude (BuiltinUnit)

-- | Compiling a parameterized validator for 'Scripts.AuctionFlipped.auctionUntypedValidator'
auctionValidatorCompiled :: AuctionFlipped.AuctionParams -> CompiledCode (BuiltinData -> BuiltinUnit)
auctionValidatorCompiled params =
  case $$(PlutusTx.compile [||AuctionFlipped.auctionUntypedValidator||])
    `PlutusTx.applyCode` PlutusTx.liftCodeDef params of
    Left err -> error err
    Right cc -> cc

-- | Serialized validator for 'Scripts.AuctionFlipped.auctionUntypedValidator'
auctionValidatorScript :: AuctionFlipped.AuctionParams -> C.PlutusScript C.PlutusScriptV3
auctionValidatorScript = compiledCodeToScript . auctionValidatorCompiled

-- | Save the validator script to a file
saveAuctionValidatorScript :: AuctionFlipped.AuctionParams -> FilePath -> IO ()
saveAuctionValidatorScript params filePath = do
  let script = auctionValidatorScript params
  C.writeFileTextEnvelope (C.File filePath) Nothing script >>= \case
    Left err -> print $ C.displayError err
    Right () -> putStrLn $ "Serialized script to: " ++ filePath

module Bitcoin.HD exposing (subscribeToDerivation, deriveAddress)

import Bitcoin.Ports as Ports

subscribeToDerivation : (String -> msg) -> Sub msg
subscribeToDerivation =
  Ports.derivation

deriveAddress : String -> Int -> Cmd msg
deriveAddress xpub index =
  Ports.derive { xpub = xpub, index = index }

port module Bitcoin.Ports exposing (..)

import Bitcoin.HD exposing (DerivationRequest)

port derive : DerivationRequest -> (Cmd msg)
port derivation : (String -> msg) -> Sub msg

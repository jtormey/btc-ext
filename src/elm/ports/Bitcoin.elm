port module Ports.Bitcoin exposing (..)

import Types exposing (Model)

type alias DerivationRequest =
  { xpub: String
  , index: Int
  }

port derive : DerivationRequest -> (Cmd msg)
port derivation : (String -> msg) -> Sub msg

derivationRequest : Model -> DerivationRequest
derivationRequest model =
  { xpub = model.xpub, index = model.nextIndex }

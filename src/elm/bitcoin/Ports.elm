port module Bitcoin.Ports exposing (..)


type alias DerivationRequest =
    { xpub : String
    , index : Int
    }


port derive : DerivationRequest -> Cmd msg


port derivation : (String -> msg) -> Sub msg

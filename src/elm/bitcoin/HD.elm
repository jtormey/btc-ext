module Bitcoin.HD exposing (DerivationRequest, derivationRequest)

type alias DerivationRequest =
  { xpub: String
  , index: Int
  }

derivationRequest : String -> Int -> DerivationRequest
derivationRequest xpub index =
  { xpub = xpub, index = index }

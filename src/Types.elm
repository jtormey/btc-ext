
module Types exposing (..)

import Http

type Msg
  = Xpub String
  | Balance Float
  | Failed Http.Error
  | Derive
  | Derivation String
  | Info XpubInfo

type Status
  = Loading
  | Loaded

type alias Model =
  { xpub: String
  , address: String
  , nextIndex: Int
  , balance: Float
  , status: Status
  }

type alias XpubInfo =
  { final_balance: Float
  , account_index: Int
  }

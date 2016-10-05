
module Types exposing (..)

import Http
import Html exposing (..)

type Msg
  = Xpub String
  | Balance Float
  | Failed Http.Error
  | Derive
  | Derivation String
  | Info XpubInfo
  | ValidateXpub
  | FromStorage String
  | FromWs String

type Status
  = Loading
  | Loaded
  | LoadFailed String
  | Asking

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

type alias ChildElems = List (Html Msg)

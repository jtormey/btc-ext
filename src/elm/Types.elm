
module Types exposing (..)

import Http
import Html exposing (..)

type Msg
  = Xpub String
  | Balance Float
  | XpubResult (Result Http.Error XpubInfo)
  | Derive
  | Derivation String
  | SetLabel String
  | LastIndex Int
  | Info XpubInfo
  | ValidateXpub
  | FromStorage String

type Status
  = Loading
  | Loaded
  | LoadFailed String
  | Asking

type alias Model =
  { xpub: String
  , address: String
  , label: String
  , nextIndex: Int
  , lastLabeled: Int
  , balance: Float
  , status: Status
  }

type alias XpubInfo =
  { final_balance: Float
  , account_index: Int
  }

type alias ChildElems = List (Html Msg)


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
  | ValidateXpub
  | FromStorage String
  | Logout
  | Home
  | ViewLabels
  | ReadLabels String

type Status
  = Loading
  | Loaded
  | LoadFailed String
  | Asking
  | Labels

type alias Model =
  { xpub: String
  , address: String
  , label: String
  , nextIndex: Int
  , lastLabeled: Int
  , balance: Float
  , status: Status
  , labels: List LabelEntry
  }

type alias XpubInfo =
  { final_balance: Float
  , account_index: Int
  }

type alias LabelEntry =
  { index: Int
  , label: String
  }

type alias ChildElems = List (Html Msg)


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

type View
  = Loading
  | LoadFailed String
  | HomeView
  | LabelsView

type Account
  = Empty
  | NotEmpty
    { xpub : String
    , labels : List LabelEntry
    }

type alias Model =
  { account: Account
  -- state
  , view: View
  , nextIndex: Int
  , lastLabeled: Int
  , balance: Float
  , address: String
  -- fields
  , xpub: String
  , label: String
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

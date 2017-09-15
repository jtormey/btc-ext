module Types exposing (..)

import Http
import Html exposing (..)

type Msg
  = Xpub String
  | Balance Float
  | XpubResult (Result Http.Error XpubInfo)
  | Derive String String
  | Derivation String
  | SetLabel String
  | ValidateXpub
  | Logout
  | Show View
  | StoreSub (Result String AccountInfo)

type View
  = Loading
  | LoadFailed String
  | HomeView
  | LabelsView

type alias Model =
  { account: Maybe AccountInfo
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

type alias AccountInfo =
  { xpub : String
  , labels : List LabelEntry
  }

type alias XpubInfo =
  { address: String
  , final_balance: Float
  , account_index: Int
  }

type alias LabelEntry =
  { index: Int
  , label: String
  }

type alias ChildElems = List (Html Msg)

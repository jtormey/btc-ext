module Types exposing (..)

import Http
import Html exposing (..)

type Msg
  = StoreSub (Result String AccountInfo)
  | XpubResult (Result Http.Error XpubInfo)
  | Derivation String
  | SetField Field
  | Show View
  | Logout
  | ValidateXpub
  | Derive String String

type View
  = Loading
  | LoadFailed String
  | HomeView
  | LabelsView

type Field
  = XpubField String
  | LabelField String

type alias Model =
  { account: Maybe AccountInfo
  , view: View
  , nextIndex: Int
  , balance: Float
  , address: String
  , xpubField: String
  , labelField: String
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

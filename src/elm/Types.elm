module Types exposing (..)

import Http
import Html exposing (..)
import Dict exposing (Dict)

type Msg
  = StoreSub (Result String AccountInfo)
  | DerivationSub (Result String AddressInfo)
  | XpubResult (Result Http.Error XpubInfo)
  | SetField Field
  | Show View
  | Logout
  | Derive String Int
  | SubmitXpub
  | SubmitLabel String String

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
  , index: Int
  , balance: Float
  , derivations: Dict Int String
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

type alias AddressInfo =
  { index : Int
  , address : String
  }

module Types exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Http


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
    | DeleteLabel Int


type View
    = ErrorView String
    | HomeView
    | LabelsView
    | SettingsView


type Field
    = XpubField String
    | LabelField String


type alias Model =
    { account : Maybe AccountInfo
    , info : Maybe XpubInfo
    , view : View
    , index : Int
    , derivations : Dict Int String
    , xpubField : String
    , labelField : String
    }


type alias AccountInfo =
    { xpub : String
    , labels : List LabelEntry
    }


type alias XpubInfo =
    { address : String
    , balance : Float
    , index : Int
    }


type alias LabelEntry =
    { index : Int
    , label : String
    }


type alias AddressInfo =
    { index : Int
    , address : String
    }

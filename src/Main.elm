
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Json exposing (object2, float, int, (:=))
import Task exposing (..)
import String exposing (toFloat)
import Helpers exposing (..)
import Bitcoin exposing (..)
import Components exposing (..)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- types

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

-- initialization

model : Model
model =
  { xpub = "xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx"
  , address = ""
  , nextIndex = 0
  , balance = 0
  , status = Loading
  }

init : (Model, Cmd Msg)
init = (model, getInfo model.xpub)

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  derivation Derivation

-- update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Xpub xpub ->
      ({ model | xpub = xpub }, Cmd.none)
    Balance balance ->
      ({ model | balance = balance }, Cmd.none)
    Failed err ->
      (model, Cmd.none)
    Derive ->
      (model , derive (derivationRequest model))
    Derivation address ->
      ({ model | address = address, nextIndex = model.nextIndex + 1 }, Cmd.none)
    Info info ->
      let
        newModel =
          { model
          | balance = info.final_balance
          , nextIndex = info.account_index
          , status = Loaded
          }
      in
        (newModel, derive (derivationRequest newModel))

-- views

loadingView : Html Msg
loadingView =
  div [ class "container" ] [ text "Loading..." ]

homeView : Model -> Html Msg
homeView model =
  let
    bal = div [ class "bal-container" ] [ balance model.balance ]
    qr = div [ class "qr-container" ] [ qrCode 150 model.address ]
    addr = div [ class "addr-container" ] [ span [] [ text model.address ] ]
    derive = div [] [ stdButton Derive "Derive Next" ]
  in
    div [ class "container" ] [ bal, qr, addr, derive ]

view : Model -> Html Msg
view model =
  case model.status of
    Loading ->
      loadingView
    Loaded ->
      homeView model

-- helper functions, should find a way to move

getInfo : String -> Cmd Msg
getInfo xpub =
  let
    url = multiAddr xpub
    decodeUrl = Json.at [ "addresses", "0" ] xpubDecoder
  in
    Task.perform Failed Info (Http.get decodeUrl url)

xpubDecoder : Json.Decoder XpubInfo
xpubDecoder =
  object2 XpubInfo
    ("final_balance" := float)
    ("account_index" := int)

derivationRequest : Model -> DerivationRequest
derivationRequest model =
  { xpub = model.xpub, index = model.nextIndex }


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

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

subscriptions : Model -> Sub Msg
subscriptions model =
  derivation Derivation

type alias Model =
  { xpub: String
  , address: String
  , nextIndex: Int
  , balance: Float
  }

type alias XpubInfo =
  { final_balance: Float
  , account_index: Int
  }

xpubDecoder : Json.Decoder XpubInfo
xpubDecoder =
  object2 XpubInfo
    ("final_balance" := float)
    ("account_index" := int)

model : Model
model =
  { xpub = "xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx"
  , address = ""
  , nextIndex = 0
  , balance = 0
  }

derivationRequest : Model -> DerivationRequest
derivationRequest model =
  { xpub = model.xpub, index = model.nextIndex }

init : (Model, Cmd Msg)
init = (model, getBalance model.xpub)

type Msg
  = Xpub String
  | Balance Float
  | Failed Http.Error
  | Derive
  | Derivation String
  | Info XpubInfo

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
          }
      in
        (newModel, derive (derivationRequest newModel))

view : Model -> Html Msg
view model =
  let
    bal =
      div [ class "bal-container" ]
        [ span [] [ text (
          if model.balance == 0
            then "No Balance"
            else showBalance model.balance
          ) ]
        ]
    qr =
      div [ class "qr-container" ]
        [ img [ src (makeQr model.address), width 150, height 150 ] []
        ]
    addr =
      div [ class "addr-container" ]
        [ span [] [ text model.address ]
        ]
    derive =
      div []
        [ button [ onClick Derive ] [ text ("Derive Next: " ++ (toString model.nextIndex)) ]
        ]
  in
    div [ class "container" ] [ bal, qr, addr, derive ]

getBalance : String -> Cmd Msg
getBalance xpub =
  let
    url = multiAddr xpub
    decodeUrl = Json.at [ "addresses", "0" ] xpubDecoder
  in
    Task.perform Failed Info (Http.get decodeUrl url)

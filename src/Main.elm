
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Json exposing ((:=))
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
init =
  (model
  , Cmd.batch [ getBalance model.xpub, derive (derivationRequest model) ]
  )

type Msg
  = Xpub String
  | Balance Float
  | Failed Http.Error
  | Derive
  | Derivation String

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
        [ button [ onClick Derive ] [ text "Derive" ]
        ]
  in
    div [ class "container" ] [ bal, qr, addr, derive ]

getBalance : String -> Cmd Msg
getBalance xpub =
  let
    url = multiAddr xpub
    decodeUrl = Json.at [ xpub, "final_balance" ] Json.float
  in
    Task.perform Failed Balance (Http.get decodeUrl url)

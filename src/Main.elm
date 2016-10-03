
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import String exposing (toFloat)
import Helpers exposing (..)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

type alias Model =
  { address: String
  , balance: Float
  }

model: Model
model =
  { address = "1LeKvPwg5jpN9ragZ51b4jM6K8nWERCZXt"
  , balance = 0
  }

init : (Model, Cmd Msg)
init =
  (model, getBalance model.address)

type Msg = Address String | Balance Float | Failed Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Address address ->
      ({ model | address = address }, Cmd.none)
    Balance balance ->
      ({ model | balance = balance }, Cmd.none)
    Failed err ->
      (model, Cmd.none)

view : Model -> Html Msg
view model =
  let
    showBal = toString << fromSatoshi
    bal =
      div [ class "bal-container" ]
        [ span [] [ text (if model.balance == 0 then "Error" else showBal model.balance) ]
        ]
    qr =
      div [ class "qr-container" ]
        [ img [ src ("https://blockchain.info/qr?data=" ++ model.address), width 150 ] []
        ]
    addr =
      div [ class "addr-container" ]
        [ span [] [ text model.address ]
        ]
  in
    div [ class "container" ] [ bal, qr, addr ]

getBalance : String -> Cmd Msg
getBalance address =
  let
    url = "https://blockchain.info/balance?cors=true&active=" ++ address
    decodeUrl = Json.at [ address, "final_balance" ] Json.float
  in
    Task.perform Failed Balance (Http.get decodeUrl url)

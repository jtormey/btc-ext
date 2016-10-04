
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Helpers exposing (..)
import Bitcoin exposing (derive, derivation, derivationRequest)
import Components exposing (..)
import Types exposing (..)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- initialization
-- "xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx"

model : Model
model =
  { xpub = ""
  , address = ""
  , nextIndex = 0
  , balance = 0
  , status = Asking
  }

init : (Model, Cmd Msg)
init = (model, Cmd.none)

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
      ({ model | status = LoadFailed (toString err) }, Cmd.none)
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
    ValidateXpub ->
      if isXpub model.xpub
        then ({ model | status = Loading }, getInfo model.xpub)
        else ({ model | status = Asking }, Cmd.none)

-- views

askForXpubView : ChildElems
askForXpubView =
  [ span [] [ text "Enter an xpub" ]
  , input [ value model.xpub, onInput Xpub ] []
  , stdButton ValidateXpub "Continue"
  ]

statusView : String -> ChildElems
statusView status = [ text status ]

homeView : Model -> ChildElems
homeView model =
  let
    bal = div [ class "bal-container" ] [ balance model.balance ]
    qr = div [ class "qr-container" ] [ qrCode 150 model.address ]
    addr = div [ class "addr-container" ] [ span [] [ text model.address ] ]
    derive = div [] [ stdButton Derive "Derive Next" ]
  in
    [ bal, qr, addr, derive ]

view : Model -> Html Msg
view model =
  let childElems =
    case model.status of
      Asking -> askForXpubView
      Loading -> statusView "Loading..."
      LoadFailed err -> statusView err
      Loaded -> homeView model
  in div [ class "container" ] childElems

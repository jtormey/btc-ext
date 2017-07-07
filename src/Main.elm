import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import WebSocket
import Debug exposing (log)
import String exposing (split)
import List exposing (take, head, drop)
import Helpers exposing (..)
import Bitcoin exposing (derive, derivation, derivationRequest)
import Storage exposing (set, get, storage)
import Labels as Labels
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

model : Model
model =
  { xpub = ""
  , address = ""
  , label = ""
  , nextIndex = 0
  , lastLabeled = 0
  , balance = 0
  , status = Loading
  }

init : (Model, Cmd Msg)
init = (model, get "xpub")

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ derivation Derivation
  , storage FromStorage
  , Labels.lastIndex LastIndex
  , WebSocket.listen "wss://blockchain.info/inv" FromWs
  ]

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
      let cmds =
        [ Labels.save ((toString (model.nextIndex - 1)) ++ "," ++ model.label)
        , derive (derivationRequest model)
        ]
      in
        ({ model | label = "" }, Cmd.batch cmds)
    Derivation address ->
      ({ model | address = address, nextIndex = model.nextIndex + 1 }, Cmd.none)
    SetLabel label ->
      ({ model | label = label }, Cmd.none)
    LastIndex index ->
      ({ model | lastLabeled = index }, Cmd.none)
    Info info ->
      let
        newModel =
          { model
          | balance = info.final_balance
          , nextIndex = (Basics.max info.account_index (model.lastLabeled + 1))
          , status = Loaded
          }
      in
        (newModel, derive (derivationRequest newModel))
    ValidateXpub ->
      let
        saveAndLoad = Cmd.batch [set ("xpub," ++ model.xpub), getInfo model.xpub, xpubSub model.xpub]
      in
        if isXpub model.xpub
          then ({ model | status = Loading }, saveAndLoad)
          else ({ model | status = Asking }, Cmd.none)
    FromStorage data ->
      case setXpub model (extract "xpub" data) of
        Just m -> (m, Cmd.batch [getInfo m.xpub, xpubSub m.xpub])
        Nothing -> ({ model | status = Asking }, Cmd.none)
    FromWs msg ->
      (model, getInfo model.xpub)

-- views

askForXpubView : ChildElems
askForXpubView =
  [ span [] [ text "Enter an xpub" ]
  , div []
    [ input [ value model.xpub, onInput Xpub ] []
    , stdButton ValidateXpub "Continue"
    ]
  ]

statusView : String -> ChildElems
statusView status = [ text status ]

saveForm : String -> Html Msg
saveForm label = div []
  [ input [ value label, onInput SetLabel ] []
  , stdButton Derive "Derive Next"
  ]

homeView : Model -> ChildElems
homeView model =
  let
    bal = balance model.balance
    qr = div [ class "pad-2" ] [ qrCode 150 model.address ]
    addr = span [ class "break" ] [ text model.address ]
    derive = saveForm model.label
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
  in div [ class "container" ] (enclose childElems)


import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Debug exposing (log)
import String exposing (split)
import List exposing (take, head, drop)
import Helpers exposing (..)
import Bitcoin exposing (derive, derivation, derivationRequest)
import Storage exposing (set, get, storage)
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
  , nextIndex = 0
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
      let
        saveAndLoad = Cmd.batch [set ("xpub," ++ model.xpub), getInfo model.xpub]
      in
        if isXpub model.xpub
          then ({ model | status = Loading }, saveAndLoad)
          else ({ model | status = Asking }, Cmd.none)
    FromStorage data ->
      let
        kv = split "," data
        key = head kv
        val = head (drop 1 kv)
      in
        case key of
          Just "xpub" ->
            if Maybe.map isXpub val == Just True
              then ({ model | xpub = unwrapStr val }, getInfo (unwrapStr val))
              else ({ model | status = Asking }, Cmd.none)
          _ ->
            (model, Cmd.none)

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

homeView : Model -> ChildElems
homeView model =
  let
    bal = balance model.balance
    qr = div [ class "pad-2" ] [ qrCode 150 model.address ]
    addr = span [ class "break" ] [ text model.address ]
    derive = stdButton Derive "Derive Next"
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

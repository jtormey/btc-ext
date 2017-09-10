import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Debug exposing (log)
import String exposing (split)
import List exposing (take, head, drop)
import Helpers exposing (..)
import Bitcoin exposing (derive, derivation, derivationRequest)
import Storage exposing (set, get, remove, storage)
import Labels as Labels
import Components exposing (..)
import Types exposing (..)

main =
  Html.program
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
  , labels = []
  }

init : (Model, Cmd Msg)
init = (model, get "xpub")

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ derivation Derivation
  , storage FromStorage
  , Labels.readResponse ReadLabels
  , Labels.lastIndex LastIndex
  ]

-- update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Xpub xpub ->
      ({ model | xpub = xpub }, Cmd.none)
    Balance balance ->
      ({ model | balance = balance }, Cmd.none)
    XpubResult (Ok info) ->
      update (Info info) model
    XpubResult (Err err) ->
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
        saveAndLoad = Cmd.batch [set ("xpub," ++ model.xpub), getInfo model.xpub]
      in
        if isXpub model.xpub
          then ({ model | status = Loading }, saveAndLoad)
          else ({ model | status = Asking }, Cmd.none)
    FromStorage data ->
      case setXpub model (extract "xpub" data) of
        Just m -> (m, getInfo m.xpub)
        Nothing -> ({ model | status = Asking }, Cmd.none)
    Logout ->
      ({ model | status = Asking }, remove "xpub")
    ViewLabels ->
      ({ model | status = Loading }, Labels.readLabels ())
    ReadLabels labelsStr ->
      case decodeLabelsStr labelsStr of
        Ok labels -> ({ model | status = Labels, labels = labels }, Cmd.none)
        Err err -> ({ model | status = LoadFailed err }, Cmd.none)
    Home ->
      ({ model | status = Loaded }, Cmd.none)

-- views

askForXpubView : ChildElems
askForXpubView =
  [ div [ class "login-view" ]
    [ div [ class "maintext mbl" ] [ text "Enter an xpub to get started" ]
    , div [ class "w100 flex-center" ]
      [ input [ class "text-input", value model.xpub, onInput Xpub ] []
      , stdButton ValidateXpub False "Continue"
      ]
    ]
  ]

statusView : String -> ChildElems
statusView status = [ div [ class "maintext" ] [ text status ] ]

homeView : Model -> ChildElems
homeView model =
  let
    bal = balance model.balance
    qr = qrCode 150 model.address
    addr = div [ class "subtext" ] [ text model.address ]
    derive = inputLabelForm model.label
  in
    [ div [ class "home-view" ]
      [ qr
      , div [ class "home-info" ]
        [ div [ ] [ bal, addr ]
        , derive
        ]
      ]
    ]

labelsView : Model -> ChildElems
labelsView model =
  let
    makeLabel entry = div [ class "label-entry" ]
      [ div [] [ text entry.label ]
      , div [] [ text ("index: " ++ (toString entry.index)) ]
      ]
  in
    [ div [ class "label-view" ] (
      List.map makeLabel model.labels |> List.reverse
    ) ]

view : Model -> Html Msg
view model =
  let
    childElems =
      case model.status of
        Asking -> askForXpubView
        Loading -> statusView "Loading..."
        LoadFailed err -> statusView err
        Loaded -> homeView model
        Labels -> labelsView model
    headerActions =
      if model.status == Loaded || model.status == Labels
        then
          [ stdLink Home "Home"
          , stdLink ViewLabels "Labels"
          , stdLink Logout "Logout"
          ]
        else
          []
  in div [ class "container" ]
    [ extHeader headerActions
    , div [ class "body" ] childElems
    ]

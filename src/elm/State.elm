module State exposing (initialState, subscriptions, update)

import Debug exposing (log)
import String exposing (split)
import List exposing (take, head, drop)
import Helpers exposing (..)
import Bitcoin.Ports as Bitcoin
import Bitcoin.HD as HD
import Ports.Storage as Storage exposing (storage)
import Ports.Labels as Labels
import Components exposing (..)
import Types exposing (..)

-- model

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

initialState : (Model, Cmd Msg)
initialState = (model, Storage.get "xpub")

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ Bitcoin.derivation Derivation
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
        , Bitcoin.derive (HD.derivationRequest model.xpub model.nextIndex)
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
        m =
          { model
          | balance = info.final_balance
          , nextIndex = (Basics.max info.account_index (model.lastLabeled + 1))
          , status = Loaded
          }
      in
        (m, Bitcoin.derive (HD.derivationRequest m.xpub m.nextIndex))
    ValidateXpub ->
      let
        saveAndLoad = Cmd.batch
          [ Storage.set ("xpub," ++ model.xpub)
          , getInfo model.xpub
          ]
      in
        if isXpub model.xpub
          then ({ model | status = Loading }, saveAndLoad)
          else ({ model | status = Asking }, Cmd.none)
    FromStorage data ->
      case setXpub model (extract "xpub" data) of
        Just m -> (m, getInfo m.xpub)
        Nothing -> ({ model | status = Asking }, Cmd.none)
    Logout ->
      ({ model | status = Asking }, Storage.remove "xpub")
    ViewLabels ->
      ({ model | status = Loading }, Labels.readLabels ())
    ReadLabels labelsStr ->
      case decodeLabelsStr labelsStr of
        Ok labels -> ({ model | status = Labels, labels = labels }, Cmd.none)
        Err err -> ({ model | status = LoadFailed err }, Cmd.none)
    Home ->
      ({ model | status = Loaded }, Cmd.none)

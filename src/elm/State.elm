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

xpubKey = "@btc-ext:xpub"

-- model

model : Model
model =
  { account = Empty
  -- state
  , view = Loading
  , nextIndex = 0
  , balance = 0
  , address = ""
  -- fields
  , xpub = ""
  , label = ""
  }

initialState : (Model, Cmd Msg)
initialState = (model, Storage.get xpubKey)

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
      let
        m =
          { model
          | balance = info.final_balance
          , nextIndex = (Basics.max info.account_index (model.lastLabeled + 1))
          , view = HomeView
          }
      in
        (m, Bitcoin.derive (HD.derivationRequest m.xpub m.nextIndex))
    XpubResult (Err err) ->
      ({ model | view = LoadFailed (toString err) }, Cmd.none)
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
    ValidateXpub ->
      let
        saveAndLoad = Cmd.batch
          [ Storage.set (xpubKey ++ "," ++ model.xpub)
          , getInfo model.xpub
          ]
      in
        if isXpub model.xpub
          then ({ model | view = Loading }, saveAndLoad)
          else ({ model }, Cmd.none)
    FromStorage data ->
      case setXpub model (extract xpubKey data) of
        Just m -> (m, getInfo m.xpub)
        Nothing -> ({ model | status = Asking }, Cmd.none)
    Logout ->
      ({ model | status = Asking }, Storage.remove xpubKey)
    ViewLabels ->
      ({ model | status = Loading }, Labels.readLabels ())
    ReadLabels labelsStr ->
      case decodeLabelsStr labelsStr of
        Ok labels -> ({ model | status = Labels, labels = labels }, Cmd.none)
        Err err -> ({ model | status = LoadFailed err }, Cmd.none)
    Home ->
      ({ model | status = Loaded }, Cmd.none)

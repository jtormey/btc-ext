module State exposing (initialState, subscriptions, update)

import Helpers exposing (..)
import Bitcoin.Ports as Bitcoin
import Bitcoin.HD as HD
import Storage.Store as Store
import Types exposing (..)

xpubKey = "@btc-ext:xpub"

-- model

model : Model
model =
  { account = Nothing
  , view = Loading
  , nextIndex = 0
  , lastLabeled = 0
  , balance = 0
  , address = ""
  , xpub = ""
  , label = ""
  }

initialState : (Model, Cmd Msg)
initialState = (model, Store.loadStore)

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  [ Bitcoin.derivation Derivation
  , Store.subscribeToStore StoreSub
  ]

-- update

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    StoreSub (Ok account) ->
      let
        getLastLabeled = (List.map (\x -> x.index)) >> (List.foldl Basics.max 0)
      in
        (
          { model
          | account = Just account
          , lastLabeled = getLastLabeled account.labels
          }
        , getInfo account.xpub
        )
    StoreSub (Err err) ->
      (model, Cmd.none)
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
          , view = if model.view == Loading then HomeView else model.view
          }
      in
        (m, Bitcoin.derive (HD.derivationRequest info.address m.nextIndex))
    XpubResult (Err err) ->
      ({ model | view = LoadFailed (toString err) }, Cmd.none)
    Derive xpub label ->
      let cmds =
        [ Store.syncStore (Maybe.map (\x -> { x | labels = { label = label, index = model.nextIndex - 1 } :: x.labels }) model.account)
        , Bitcoin.derive (HD.derivationRequest xpub model.nextIndex)
        ]
      in
        ({ model | label = "" }, Cmd.batch cmds)
    Derivation address ->
      ({ model | address = address, nextIndex = model.nextIndex + 1 }, Cmd.none)
    SetLabel label ->
      ({ model | label = label }, Cmd.none)
    ValidateXpub ->
      let
        account = Just
          { xpub = model.xpub
          , labels = []
          }
        saveAndLoad = Cmd.batch
          [ Store.syncStore account
          , getInfo model.xpub
          ]
      in
        if isXpub model.xpub
          then ({ model | view = Loading }, saveAndLoad)
          else (model, Cmd.none)
    Logout ->
      ({ model | account = Nothing }, Store.clearStore)
    ViewLabels ->
      ({ model | view = LabelsView }, Cmd.none)
    Home ->
      ({ model | view = HomeView }, Cmd.none)

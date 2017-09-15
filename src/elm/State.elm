module State exposing (initialState, subscriptions, update)

import Debug exposing (log)
import Helpers exposing (..)
import Bitcoin.Ports as Bitcoin
import Bitcoin.HD as HD
import Storage.Store as Store
import Types exposing (..)

-- model

model : Model
model =
  { account = Nothing
  , view = Loading
  , nextIndex = 0
  , balance = 0
  , address = ""
  , xpubField = ""
  , labelField = ""
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
  case (log "Msg" msg) of
    -- handle results
    StoreSub (Ok account) ->
      let
        cmd = case model.account of
          Just { xpub } as account -> Cmd.none
          _ -> getInfo account.xpub
      in
        ({ model | account = Just account }, cmd)

    StoreSub (Err err) ->
      (model, Cmd.none)

    XpubResult (Ok info) ->
      let
        lastLabeled =
          model.account
          |> Maybe.map (\a -> a.labels
            |> List.map (\x -> x.index)
            |> List.foldl Basics.max 0)
          |> Maybe.withDefault 0
        m =
          { model
          | balance = info.final_balance
          , nextIndex = Basics.max info.account_index (lastLabeled + 1)
          , view = if model.view == Loading then HomeView else model.view
          }
      in
        (m, Bitcoin.derive (HD.derivationRequest info.address m.nextIndex))

    XpubResult (Err err) ->
      ({ model | view = LoadFailed (toString err) }, Cmd.none)

    Derivation address ->
      ({ model | address = address, nextIndex = model.nextIndex + 1 }, Cmd.none)

    -- handle inputs
    SetField (XpubField xpub) ->
      ({ model | xpubField = xpub }, Cmd.none)

    SetField (LabelField label) ->
      ({ model | labelField = label }, Cmd.none)

    -- handle ui events
    Show view ->
      ({ model | view = view }, Cmd.none)

    Logout ->
      ({ model | account = Nothing }, Store.clearStore)

    SubmitXpub ->
      let
        account = Just
          { xpub = model.xpubField
          , labels = []
          }
        saveAndLoad = Cmd.batch
          [ Store.syncStore account
          , getInfo model.xpubField
          ]
      in
        ({ model | xpubField = "", view = Loading }, saveAndLoad)

    SubmitLabel xpub label ->
      let
        labelEntry =
          { label = label
          , index = model.nextIndex - 1 }
        withLabelEntry store =
          { store | labels = labelEntry :: store.labels }
        cmds =
          [ Store.syncStore (Maybe.map withLabelEntry model.account)
          , Bitcoin.derive (HD.derivationRequest xpub model.nextIndex)
          ]
      in
        ({ model | labelField = "" }, Cmd.batch cmds)

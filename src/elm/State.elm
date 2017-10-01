module State exposing (initialState, subscriptions, update)

import Bitcoin.HD as Bitcoin
import Debug exposing (log)
import Dict
import Helpers exposing (..)
import Storage.Store as Store
import Types exposing (..)


-- model


model : Model
model =
    { account = Nothing
    , view = Loading
    , index = 0
    , derivations = Dict.empty
    , balance = 0
    , xpubField = ""
    , labelField = ""
    }


initialState : ( Model, Cmd Msg )
initialState =
    ( model, Store.loadStore )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Store.subscribeToStore StoreSub
        , Bitcoin.subscribeToDerivation DerivationSub
        ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case log "Msg" msg of
        -- handle results
        StoreSub (Ok account) ->
            ( { model | account = Just account }
            , case model.account of
                (Just { xpub }) as account ->
                    Cmd.none

                _ ->
                    getInfo account.xpub
            )

        StoreSub (Err err) ->
            ( model, Cmd.none )

        DerivationSub (Ok info) ->
            ( { model
                | derivations = Dict.insert info.index info.address model.derivations
              }
            , Cmd.none
            )

        DerivationSub (Err _) ->
            ( model, Cmd.none )

        XpubResult (Ok info) ->
            let
                balance =
                    info.final_balance

                index =
                    model.account
                        |> Maybe.map (.labels >> List.map .index)
                        |> Maybe.andThen List.maximum
                        |> Maybe.withDefault 0
                        |> (Basics.max info.account_index << (+) 1)

                view =
                    if model.view == Loading then
                        HomeView
                    else
                        model.view
            in
            ( { model | balance = balance, index = index, view = view }
            , Bitcoin.deriveAddress info.address index
            )

        XpubResult (Err err) ->
            ( { model | view = LoadFailed (toString err) }, Cmd.none )

        -- handle inputs
        SetField (XpubField xpub) ->
            ( { model | xpubField = xpub }, Cmd.none )

        SetField (LabelField label) ->
            ( { model | labelField = label }, Cmd.none )

        -- handle ui events
        Show view ->
            ( { model | view = view }, Cmd.none )

        Logout ->
            ( { model | account = Nothing }, Store.clearStore )

        Derive xpub index ->
            ( model, Bitcoin.deriveAddress xpub index )

        SubmitXpub ->
            ( { model | xpubField = "", view = Loading }
            , Store.syncStore (Just { xpub = model.xpubField, labels = [] })
            )

        SubmitLabel xpub label ->
            let
                nextIndex =
                    model.index + 1

                labelEntry =
                    { label = label
                    , index = model.index
                    }

                withLabelEntry store =
                    { store | labels = labelEntry :: store.labels }

                cmds =
                    [ Store.syncStore (Maybe.map withLabelEntry model.account)
                    , Bitcoin.deriveAddress xpub nextIndex
                    ]
            in
            ( { model | labelField = "", index = nextIndex }, Cmd.batch cmds )

        DeleteLabel index ->
            let
                deleteLabel account =
                    { account | labels = List.filter (.index >> (/=) index) account.labels }

                sync =
                    Store.syncStore (Maybe.map deleteLabel model.account)

                info =
                    model.account
                        |> Maybe.map (.xpub >> getInfo)
                        |> Maybe.withDefault Cmd.none

                cmds =
                    if model.index == index + 1 then
                        [ sync, info ]
                    else
                        [ sync ]
            in
            ( model, Cmd.batch cmds )

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
            let
                cmd =
                    case model.account of
                        (Just { xpub }) as account ->
                            Cmd.none

                        _ ->
                            getInfo account.xpub
            in
            ( { model | account = Just account }, cmd )

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
                lastLabeled =
                    model.account
                        |> Maybe.map
                            (\a ->
                                a.labels
                                    |> List.map (\x -> x.index)
                                    |> List.foldl Basics.max 0
                            )
                        |> Maybe.withDefault 0

                m =
                    { model
                        | balance = info.final_balance
                        , index = Basics.max info.account_index (lastLabeled + 1)
                        , view =
                            if model.view == Loading then
                                HomeView
                            else
                                model.view
                    }
            in
            ( m, Bitcoin.deriveAddress info.address m.index )

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
            let
                account =
                    Just
                        { xpub = model.xpubField
                        , labels = []
                        }

                syncAccount =
                    Store.syncStore account
            in
            ( { model | xpubField = "", view = Loading }, syncAccount )

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
                removeLabel account =
                    { account | labels = List.filter (\l -> l.index /= index) account.labels }

                sync =
                    Store.syncStore (Maybe.map removeLabel model.account)

                info =
                    model.account
                        |> Maybe.map (\a -> getInfo a.xpub)
                        |> Maybe.withDefault Cmd.none

                cmds =
                    sync
                        :: (if model.index == index + 1 then
                                [ info ]
                            else
                                []
                           )
            in
            ( model, Cmd.batch cmds )

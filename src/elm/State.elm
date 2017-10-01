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
    , info = Nothing
    , view = Loading
    , index = 0
    , derivations = Dict.empty
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


deriveIndex : Maybe AccountInfo -> Maybe XpubInfo -> Int
deriveIndex account info =
    Basics.max
        (account
            |> Maybe.map (.labels >> List.map .index)
            |> Maybe.andThen List.maximum
            |> Maybe.withDefault 0
            |> (+) 1
        )
        (info
            |> Maybe.map .index
            |> Maybe.withDefault 0
        )


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
                index =
                    deriveIndex model.account (Just info)

                view =
                    if model.view == Loading then
                        HomeView
                    else
                        model.view
            in
            ( { model | info = Just info, view = view, index = index }
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

                accountWithoutLabel =
                    Maybe.map deleteLabel model.account
            in
            ( { model | index = deriveIndex accountWithoutLabel model.info }
            , Store.syncStore accountWithoutLabel
            )

module View exposing (rootView)

import Dict
import Helpers exposing (isXpub, makeQr, showBalance)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)


-- components


extHeader : List (Html Msg) -> Html Msg
extHeader actions =
    div [ class "header" ]
        [ span [ class "header-brand" ] [ text "BTC EXT" ]
        , div [ class "header-actions" ] actions
        ]


balance : Float -> Html Msg
balance satoshi =
    let
        balanceText =
            if satoshi == 0 then
                "No Balance"
            else
                showBalance satoshi
    in
    div [ class "maintext" ] [ text balanceText ]


qrCode : Int -> String -> Html Msg
qrCode qrSize address =
    img [ src (makeQr address), width qrSize, height qrSize ] []


stdButton : Msg -> Bool -> String -> Html Msg
stdButton action isDisabled str =
    button [ class "std-button", onClick action, disabled isDisabled ] [ text str ]


stdLink : Msg -> Bool -> String -> Html Msg
stdLink action selected str =
    let
        className =
            if selected then
                "std-link selected"
            else
                "std-link"
    in
    span [ class className, onClick action ] [ text str ]


inputLabelForm : String -> String -> Html Msg
inputLabelForm xpub label =
    div [ class "flex-center" ]
        [ input [ class "text-input", value label, onInput (SetField << LabelField) ] []
        , stdButton (SubmitLabel xpub label) (label == "") "Save Label"
        ]



-- views


askForXpubView : String -> Html Msg
askForXpubView xpub =
    div [ class "login-view" ]
        [ div [ class "maintext mbl" ] [ text "Enter an xpub to get started" ]
        , div [ class "w100 flex-center" ]
            [ input [ class "text-input", value xpub, onInput (SetField << XpubField) ] []
            , stdButton SubmitXpub (not <| isXpub xpub) "Continue"
            ]
        ]


statusView : String -> Html Msg
statusView status =
    div [ class "maintext" ] [ text status ]


homeView : Model -> AccountInfo -> XpubInfo -> Html Msg
homeView model account info =
    let
        address =
            Maybe.withDefault "" <| Dict.get model.index model.derivations

        bal =
            balance info.balance

        qr =
            qrCode 150 address

        addr =
            div [ class "subtext" ] [ text address ]

        derive =
            inputLabelForm account.xpub model.labelField
    in
    div [ class "home-view" ]
        [ qr
        , div [ class "home-info" ]
            [ div [] [ bal, addr ]
            , derive
            ]
        ]


labelsView : Model -> AccountInfo -> Html Msg
labelsView model account =
    let
        getText index =
            Dict.get index model.derivations
                |> Maybe.withDefault (toString index |> (++) "#")

        getAttrs index =
            class "link"
                :: (case Dict.get index model.derivations of
                        Just addr ->
                            [ href ("https://blockchain.info/address/" ++ addr), target "_blank" ]

                        Nothing ->
                            [ onClick (Derive account.xpub index) ]
                   )

        makeLabel entry =
            div [ class "label-entry" ]
                [ div [] [ text entry.label ]
                , div []
                    [ a (getAttrs entry.index) [ text (getText entry.index) ]
                    , a [ class "link red", onClick (DeleteLabel entry.index) ] [ text "Delete" ]
                    ]
                ]
    in
    if List.isEmpty account.labels then
        statusView "No Labels"
    else
        div [ class "label-view" ] (List.map makeLabel account.labels)


settingsView : Html Msg
settingsView =
    div [ class "settings-view" ]
        [ div [ class "setting" ]
            [ stdButton Logout False "Clear Local Cache"
            , text "Delete xpub and address label information."
            ]
        ]


rootView : Model -> Html Msg
rootView model =
    let
        view =
            case model.account of
                Just account ->
                    case model.info of
                        Just info ->
                            case model.view of
                                ErrorView err ->
                                    statusView err

                                HomeView ->
                                    homeView model account info

                                LabelsView ->
                                    labelsView model account

                                SettingsView ->
                                    settingsView

                        Nothing ->
                            statusView "Loading..."

                Nothing ->
                    askForXpubView model.xpubField

        shouldShowHeader =
            case model.view of
                ErrorView _ ->
                    False

                _ ->
                    model.account /= Nothing

        viewLink view title =
            stdLink (Show view) (model.view == view) title

        headerActions =
            if shouldShowHeader then
                [ viewLink HomeView "Home"
                , viewLink LabelsView "Labels"
                , viewLink SettingsView "Settings"
                ]
            else
                []
    in
    div [ class "container" ]
        [ extHeader headerActions
        , div [ class "body" ] [ view ]
        ]

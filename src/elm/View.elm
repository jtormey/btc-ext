module View exposing (rootView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (..)
import Components exposing (..)

askForXpubView : String -> ChildElems
askForXpubView xpub =
  [ div [ class "login-view" ]
    [ div [ class "maintext mbl" ] [ text "Enter an xpub to get started" ]
    , div [ class "w100 flex-center" ]
      [ input [ class "text-input", value xpub, onInput Xpub ] []
      , stdButton ValidateXpub False "Continue"
      ]
    ]
  ]

statusView : String -> ChildElems
statusView status = [ div [ class "maintext" ] [ text status ] ]

homeView : Model -> AccountInfo -> ChildElems
homeView model account =
  let
    bal = balance model.balance
    qr = qrCode 150 model.address
    addr = div [ class "subtext" ] [ text model.address ]
    derive = inputLabelForm account.xpub model.label
  in
    [ div [ class "home-view" ]
      [ qr
      , div [ class "home-info" ]
        [ div [ ] [ bal, addr ]
        , derive
        ]
      ]
    ]

labelsView : AccountInfo -> ChildElems
labelsView account =
  let
    makeLabel entry = div [ class "label-entry" ]
      [ div [] [ text entry.label ]
      , div [] [ text ("index: " ++ (toString entry.index)) ]
      ]
  in
    [ div [ class "label-view" ] (
      List.map makeLabel account.labels
    ) ]

rootView : Model -> Html Msg
rootView model =
  let
    childElems =
      case model.account of
        Just account ->
          case model.view of
            Loading -> statusView "Loading..."
            LoadFailed err -> statusView err
            HomeView -> homeView model account
            LabelsView -> labelsView account
        Nothing ->
          askForXpubView model.xpub
    headerActions =
      if model.view == HomeView || model.view == LabelsView
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

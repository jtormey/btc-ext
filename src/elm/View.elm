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

rootView : Model -> Html Msg
rootView model =
  let
    childElems =
      case model.status of
        Asking -> askForXpubView model.xpub
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

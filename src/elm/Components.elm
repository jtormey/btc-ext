module Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Helpers exposing (showBalance, makeQr)
import Types exposing (..)

extHeader : ChildElems -> Html Msg
extHeader actions = div [ class "header" ]
  [ span [ class "header-brand" ] [ text "BTC EXT" ]
  , div [ class "header-actions" ] actions
  ]

balance : Float -> Html Msg
balance satoshi =
  let
    bal = if satoshi == 0 then "No Balance" else showBalance satoshi
  in
    div [ class "maintext" ] [ text bal ]

qrCode : Int -> String -> Html Msg
qrCode qrSize address =
  img [ src (makeQr address), width qrSize, height qrSize ] []

stdButton : Msg -> Bool -> String -> Html Msg
stdButton action isDisabled str =
  button [ class "std-button", onClick action, disabled isDisabled ] [ text str ]

stdLink : Msg -> String -> Html Msg
stdLink action str =
  span [ class "std-link", onClick action ] [ text str ]

inputLabelForm : String -> Html Msg
inputLabelForm label = div [ class "flex-center" ]
  [ input [ class "text-input", value label, onInput SetLabel ] []
  , stdButton Derive (label == "") "Save Label"
  ]

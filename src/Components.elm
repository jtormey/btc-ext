
module Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Helpers exposing (showBalance, makeQr)
import Types exposing (..)

balance : Float -> Html Msg
balance satoshi =
  let
    bal = if satoshi == 0 then "No Balance" else showBalance satoshi
  in
    span [] [ text bal ]

qrCode : Int -> String -> Html Msg
qrCode qrSize address =
  img [ src (makeQr address), width qrSize, height qrSize ] []

stdButton : Msg -> Bool -> String -> Html Msg
stdButton action isDisabled str =
  button [ onClick action, disabled isDisabled ] [ text str ]

inputLabelForm : String -> Html Msg
inputLabelForm label = div []
  [ input [ value label, onInput SetLabel ] []
  , stdButton Derive (label == "") "Derive Next"
  ]

enclose : ChildElems -> ChildElems
enclose elems =
  case elems of
    e::es -> [ div [ class "child" ] [e] ] ++ (enclose es)
    [] -> []

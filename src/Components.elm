
module Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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

stdButton : Msg -> String -> Html Msg
stdButton action str =
  button [ onClick action ] [ text str ]

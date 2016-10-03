
module Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Helpers exposing (showBalance, makeQr)

balance : Float -> Html a
balance satoshi =
  let
    bal = if satoshi == 0 then "No Balance" else showBalance satoshi
  in
    span [] [ text bal ]

qrCode : Int -> String -> Html a
qrCode qrSize address =
  img [ src (makeQr address), width qrSize, height qrSize ] []

stdButton : a -> String -> Html a
stdButton action str =
  button [ onClick action ] [ text str ]

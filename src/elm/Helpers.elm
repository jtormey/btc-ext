module Helpers exposing (..)

import Http
import Json.Decode as Json exposing (field, float, int, list, string)
import String exposing (left)
import Types exposing (..)


fromSatoshi : Float -> Float
fromSatoshi =
    flip (/) 100000000


append : String -> String -> String
append =
    flip (++)


showBalance : Float -> String
showBalance =
    fromSatoshi >> toString >> append " BTC"


isXpub : String -> Bool
isXpub =
    (==) "xpub" << left 4


makeQr : String -> String
makeQr =
    (++) "https://blockchain.info/qr?data="


multiAddr : String -> String
multiAddr =
    (++) "https://blockchain.info/multiaddr?cors=true&active="


xpubDecoder : Json.Decoder XpubInfo
xpubDecoder =
    Json.map3 XpubInfo
        (field "address" string)
        (field "final_balance" float)
        (field "account_index" int)


getInfo : String -> Cmd Msg
getInfo xpub =
    let
        url =
            multiAddr xpub

        decodeUrl =
            Json.at [ "addresses", "0" ] xpubDecoder

        getInfoReq =
            Http.get url decodeUrl
    in
    Http.send XpubResult getInfoReq

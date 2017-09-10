module Helpers exposing (..)

import String exposing (left, split)
import List exposing (head, drop, length, take)
import Tuple exposing (first, second)
import Maybe exposing (withDefault)
import Json.Decode as Json exposing (map2, float, int, field)
import Http
import Types exposing (..)

fromSatoshi : Float -> Float
fromSatoshi = flip (/) 100000000

append : String -> String -> String
append = flip (++)

showBalance : Float -> String
showBalance = fromSatoshi >> toString >> append " BTC"

isXpub : String -> Bool
isXpub = ((==) "xpub") << left 4

makeQr : String -> String
makeQr = (++) "https://blockchain.info/qr?data="

multiAddr : String -> String
multiAddr = (++) "https://blockchain.info/multiaddr?cors=true&active="

xpubDecoder : Json.Decoder XpubInfo
xpubDecoder =
  map2 XpubInfo
    (field "final_balance" float)
    (field "account_index" int)


getInfo : String -> Cmd Msg
getInfo xpub =
  let
    url = multiAddr xpub
    decodeUrl = Json.at [ "addresses", "0" ] xpubDecoder
    getInfoReq = Http.get url decodeUrl
  in
    Http.send XpubResult getInfoReq

wrapStr : String -> Maybe String
wrapStr s = if s == "" then Nothing else Just s

isEmpty : List a -> Bool
isEmpty = ((==) 1) << length

isKeyValue : List a -> Maybe (List a)
isKeyValue xs = if isEmpty xs then Nothing else Just xs

stringToList : String -> Maybe (List String)
stringToList = isKeyValue << (take 2) << (split ",")

elem : Int -> List a -> Maybe a
elem i = head << (drop i)

listToTuple : List String -> (String, String)
listToTuple xs = (withDefault "" (elem 0 xs), withDefault "" (elem 1 xs))

keyValue : String -> Maybe (String, String)
keyValue s = Maybe.map listToTuple (stringToList s)

extract : String -> String -> Maybe (String)
extract key data = if (Maybe.map first (keyValue data) == Just key)
    then Maybe.andThen wrapStr (Maybe.map second (keyValue data))
    else Nothing

setXpub : Model -> Maybe String -> Maybe Model
setXpub model xpub = Maybe.map (\x -> { model | xpub = x }) xpub

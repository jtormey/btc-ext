
module Helpers exposing (..)

fromSatoshi : Float -> Float
fromSatoshi = flip (/) 100000000

append : String -> String -> String
append = flip (++)

showBalance : Float -> String
showBalance = (append " BTC") << toString << fromSatoshi

makeQr : String -> String
makeQr = (++) "https://blockchain.info/qr?data="

multiAddr : String -> String
multiAddr = (++) "https://blockchain.info/balance?cors=true&active="

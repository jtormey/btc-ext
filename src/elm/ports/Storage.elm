port module Ports.Storage exposing (..)

port set : String -> (Cmd msg)
port get : String -> (Cmd msg)
port remove : String -> (Cmd msg)
port storage : (String -> msg) -> Sub msg

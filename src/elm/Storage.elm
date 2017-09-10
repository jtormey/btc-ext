
port module Storage exposing (..)

port set : String -> (Cmd msg)
port get : String -> (Cmd msg)
port storage : (String -> msg) -> Sub msg

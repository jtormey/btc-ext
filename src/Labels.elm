
port module Labels exposing (..)

port save : String -> (Cmd msg)
port lastIndex: (Int -> msg) -> Sub msg

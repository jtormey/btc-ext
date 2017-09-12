port module Ports.Labels exposing (..)

port save : String -> (Cmd msg)
port readLabels : () -> (Cmd msg)
port readResponse : (String -> msg) -> Sub msg
port lastIndex: (Int -> msg) -> Sub msg

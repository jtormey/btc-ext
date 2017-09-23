port module Storage.Ports exposing (..)


port updateStorage : String -> Cmd msg


port fetchStorage : String -> Cmd msg


port clearStorage : String -> Cmd msg


port receiveStorage : (String -> msg) -> Sub msg

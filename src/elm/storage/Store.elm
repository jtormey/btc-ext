module Storage.Store
    exposing
        ( clearStore
        , loadStore
        , subscribeToStore
        , syncStore
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import List exposing (foldl, length)
import Storage.Ports as Ports
import Types exposing (..)


-- public


subscribeToStore : (Result String AccountInfo -> msg) -> Sub msg
subscribeToStore typeCons =
    Ports.receiveStorage (typeCons << decodeStoreJson)


loadStore : Cmd msg
loadStore =
    Ports.fetchStorage ""


clearStore : Cmd msg
clearStore =
    Ports.clearStorage ""


syncStore : Maybe AccountInfo -> Cmd msg
syncStore =
    Maybe.map (Ports.updateStorage << encodeStoreJson)
        >> Maybe.withDefault Cmd.none



-- decoding


decodeStoreJson : String -> Result String AccountInfo
decodeStoreJson =
    Decode.decodeString storeDecoder


storeDecoder : Decoder AccountInfo
storeDecoder =
    Decode.map2 AccountInfo
        (Decode.field "xpub" Decode.string)
        (Decode.field "labels" labelsDecoder)


labelsDecoder : Decoder (List LabelEntry)
labelsDecoder =
    Decode.list labelEntryDecoder


labelEntryDecoder : Decoder LabelEntry
labelEntryDecoder =
    Decode.map2 LabelEntry
        (Decode.field "index" Decode.int)
        (Decode.field "label" Decode.string)



-- encoding


encodeStoreJson : AccountInfo -> String
encodeStoreJson =
    Encode.encode 0 << encodeStore


encodeStore : AccountInfo -> Encode.Value
encodeStore { xpub, labels } =
    Encode.object
        [ ( "xpub", Encode.string xpub )
        , ( "labels", encodeLabels labels )
        ]


encodeLabels : List LabelEntry -> Encode.Value
encodeLabels =
    Encode.list << List.map encodeLabelEntry


encodeLabelEntry : LabelEntry -> Encode.Value
encodeLabelEntry { index, label } =
    Encode.object
        [ ( "index", Encode.int index )
        , ( "label", Encode.string label )
        ]

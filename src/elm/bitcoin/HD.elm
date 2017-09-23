module Bitcoin.HD exposing (deriveAddress, subscribeToDerivation)

import Bitcoin.Ports as Ports
import Json.Decode as Decode exposing (Decoder)
import Types exposing (AddressInfo)


subscribeToDerivation : (Result String AddressInfo -> msg) -> Sub msg
subscribeToDerivation typeCons =
    Ports.derivation (typeCons << decodeAddressInfo)


deriveAddress : String -> Int -> Cmd msg
deriveAddress xpub index =
    Ports.derive { xpub = xpub, index = index }


decodeAddressInfo : String -> Result String AddressInfo
decodeAddressInfo =
    Decode.decodeString addressInfoDecoder


addressInfoDecoder : Decoder AddressInfo
addressInfoDecoder =
    Decode.map2 AddressInfo
        (Decode.field "index" Decode.int)
        (Decode.field "address" Decode.string)

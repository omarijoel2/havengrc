module API exposing (getRegulations)

import Authentication
import Http
import Json.Decode as Decode exposing (Decoder, field, succeed)
import Json.Encode as Encode
import Regulation exposing (Regulation)
import Msg exposing (Msg(..))


regulationDecoder : Decoder Regulation
regulationDecoder =
    Decode.map4 Regulation
        (field "id" Decode.int)
        (field "identifier" Decode.string)
        (field "uri" Decode.string)
        (field "description" Decode.string)


regulationsUrl : String
regulationsUrl =
    "http://localhost:3000/regulation"


getRegulations : Cmd Msg
getRegulations =
    let
        _ =
            Debug.log "getRegulations called"
    in
        (Decode.list regulationDecoder)
            |> Http.get regulationsUrl
            |> Http.send NewRegulations
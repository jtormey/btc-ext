
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)

main =
  App.beginnerProgram
    { update = update
    , model = model
    , view = view
    }

type alias Model = Int

model : Model
model =
  0

type Msg = Increment | Decrement

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      model + 1
    Decrement ->
      model - 1

view : Model -> Html Msg
view model =
  div []
    [ span [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "inc" ]
    , button [ onClick Decrement, disabled (model == 0)] [ text "dec" ]
    ]

module Main exposing (..)

import Html as Html
import State as State
import View as View


main =
    Html.program
        { init = State.initialState
        , view = View.rootView
        , update = State.update
        , subscriptions = State.subscriptions
        }

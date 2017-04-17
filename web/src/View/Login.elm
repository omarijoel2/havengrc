module View.Login exposing (view)

import Authentication
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Button as Button
import Material.Options as Options exposing (css, onClick)
import Material.Scheme
import Types exposing (Model, Msg)


view : Model -> Html Msg
view model =
    div
        [ class "mdl-grid" ]
        [ div [ class "mdl-layout-spacer" ] []
        , div [ class "mdl-cell mdl-cell--4-col" ]
            [ text "Welcome to Haven GRC"
            , Button.render Types.Mdl
                [ 0 ]
                model.mdl
                [ Options.onClick (Types.AuthenticationMsg Authentication.ShowLogIn)
                , css "margin" "0 24px"
                ]
                [ text "Login" ]
            ]
        , div [ class "mdl-layout-spacer" ] []
        ]
        |> Material.Scheme.top

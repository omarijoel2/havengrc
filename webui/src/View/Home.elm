module View.Home exposing (view)

import Authentication
import Gravatar
import View.Centroid as Centroid
import Date
import List exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions, on)
import Json.Decode as Json
import Keycloak
import View.LineChart as LineChart
import Route exposing (Location(..), locFor)
import String exposing (toLower)
import Types exposing (Model, Msg)
import WebComponents.App exposing (appDrawer, appDrawerLayout, appToolbar, appHeader, appHeaderLayout, ironSelector)
import WebComponents.Paper as Paper


header : Model -> Html Msg
header model =
    appHeaderLayout
        []
        [ appHeader
            [ attribute "fixed" ""
            , attribute "slot" "header"
            , class "main-header"
            ]
            [ appToolbar
                [ classList [ ( "title-toolbar", True ), ( "nav-title-toolbar", True ) ] ]
                [ Paper.iconButton
                    [ attribute "icon" "menu"
                    , attribute "drawer-toggle" ""
                    ]
                    []
                , div [ attribute "main-title" "" ] [ text "Haven GRC" ]
                , Paper.iconButton [ attribute "icon" "search" ] []
                ]
            ]
        ]


getGravatar : String -> String
getGravatar email =
    let
        options =
            Gravatar.defaultOptions
                |> Gravatar.withDefault Gravatar.Identicon

        url =
            Gravatar.url options email
    in
        "https:" ++ url


view : Model -> Keycloak.UserProfile -> Html Msg
view model user =
    appDrawerLayout
        []
        [ appDrawer
            [ attribute "slot" "drawer"
            , id "drawer"
            ]
            [ appHeaderLayout
                [ attribute "has-scrolling-region" "" ]
                [ appHeader
                    [ attribute "fixed" ""
                    , attribute "slot" "header"
                    , class "main-header"
                    ]
                    [ appToolbar
                        [ id "profiletoolbar" ]
                        [ div [ class "user-container" ]
                            [ node "iron-image"
                                [ attribute "sizing" "contain"
                                , attribute "src" (getGravatar user.username)
                                , class "user-avatar"
                                ]
                                []
                            , p [ class "user-name" ] [ text user.username ]
                            ]
                        , node "paper-menu-button"
                            [ attribute "vertical-align" "top"
                            , class "user-menu"
                            ]
                            [ node "paper-icon-button"
                                [ attribute "icon" "arrow-drop-down"
                                , attribute "slot" "dropdown-trigger"
                                , class "dropdown-trigger"
                                ]
                                []
                            , node "paper-listbox"
                                [ attribute "slot" "dropdown-content"
                                , class "user-menu-items"
                                ]
                                [ a [ href "/auth/realms/havendev/account/" ]
                                    [ node "paper-item"
                                        []
                                        [ text "Edit Account" ]
                                    ]
                                , a [ href "#" ]
                                    [ node "paper-item"
                                        [ onClick (Types.AuthenticationMsg Authentication.LogOut) ]
                                        [ text "Log Out" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                , div [ class "iron-selector-container" ]
                    [ ironSelector
                        [ class "nav-menu"
                        , attribute "attr-for-selected" "name"
                        , attribute "selected" (selectedItem model)
                        ]
                        (List.map drawerMenuItem menuItems)
                    , div [ class "drawer-logo" ]
                        [ img
                            [ attribute "src" "/img/logo.png" ]
                            []
                        ]
                    ]
                ]
            ]
        , header model
        , body model
        ]


selectedItem : Model -> String
selectedItem model =
    let
        item =
            List.head (List.filter (\m -> m.route == model.route) menuItems)
    in
        case item of
            Nothing ->
                "dashboard"

            Just item ->
                String.toLower item.text


body : Model -> Html Msg
body model =
    div [ id "content" ]
        [ case model.route of
            Nothing ->
                dashboardBody model

            Just Home ->
                dashboardBody model

            Just Reports ->
                reportsBody model

            Just Regulations ->
                regulationsBody model

            Just Activity ->
                activityBody model

            Just _ ->
                notFoundBody model
        ]


dashboardBody : Model -> Html Msg
dashboardBody model =
    let
        data =
            [ 1, 1, 2, 3, 5, 8, 13 ]
    in
        div
            []
            [ Centroid.view data ]


reportsBody : Model -> Html Msg
reportsBody model =
    div [] [ text "This is the reports view" ]


regulationsBody : Model -> Html Msg
regulationsBody model =
    div []
        [ text "This is the regulations view"
        , ul []
            (List.map (\l -> li [] [ text l.description ]) model.regulations)
        , regulationsForm model
        ]


onValueChanged : (String -> msg) -> Html.Attribute msg
onValueChanged tagger =
    on "value-changed" (Json.map tagger Html.Events.targetValue)


regulationsForm : Model -> Html Msg
regulationsForm model =
    div
        []
        -- TODO wire up a handler to save the data from these inputs into
        -- our model when they change
        [ Paper.input
            [ attribute "label" "URI"
            , onValueChanged Types.SetRegulationURIInput
            , value model.newRegulation.uri
            ]
            []
        , Paper.input
            [ attribute "label" "identifier"
            , onValueChanged Types.SetRegulationIDInput
            , value model.newRegulation.identifier
            ]
            []
        , Paper.textarea
            [ attribute "label" "description"
            , onValueChanged Types.SetRegulationDescriptionInput
            , value model.newRegulation.description
            ]
            []
        , Paper.button
            [ attribute "raised" ""
            , onClick (Types.GetRegulations model)
            ]
            [ text "Add" ]
        , div [ class "debug" ] [ text ("DEBUG: " ++ toString model.newRegulation) ]
        ]


activityBody : Model -> Html Msg
activityBody model =
    let
        data =
            [ ( Date.fromTime 1448928000000, 2 )
            , ( Date.fromTime 1451606400000, 2 )
            , ( Date.fromTime 1454284800000, 1 )
            , ( Date.fromTime 1456790400000, 1 )
            ]
    in
        LineChart.view data


notFoundBody : Model -> Html Msg
notFoundBody model =
    div [] [ text "This is the notFound view" ]


type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route.Location
    }


menuItems : List MenuItem
menuItems =
    [ { text = "Dashboard", iconName = "icons:dashboard", route = Just Home }
    , { text = "Activity", iconName = "icons:history", route = Just Activity }
    , { text = "Reports", iconName = "av:library-books", route = Just Reports }
    , { text = "Regulations", iconName = "icons:gavel", route = Just Regulations }
    ]


drawerMenuItem : MenuItem -> Html Msg
drawerMenuItem menuItem =
    div
        [ attribute "name" (toLower menuItem.text)
        , onClick <| Types.NavigateTo <| menuItem.route
        ]
        [ node "iron-icon" [ attribute "icon" menuItem.iconName ] []
        , text (" " ++ menuItem.text)
        ]
module Modules.Kve.ServicesArea exposing (..)
import Html exposing (Html,div,text)
import Html.Attributes exposing (class,id)
import Modules.Kve.Event.KveEvents exposing (Events(..))
import Modules.Kve.Decoder.Mouse exposing (decodeMouseUp, decodeMousePosition)
import Model.PxPosition exposing (PxPosition)
import Modules.Kve.Model.KveModel exposing (ServiceTemplate)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Browser.Dom exposing (getElement, Element)
import Task
import Result
type alias Model = {
    ongoingDrag: Maybe PxPosition,
    services: List ServiceTemplate,
    hover: Bool,
    dimensions: Element
 }

outOfView: Element
outOfView = {
   scene =  { width = -1, height =  -1},
   viewport = { x = -1, y = -1, width = -1, height = -1},
   element = { x = -1, y = -1, width = -1, height = -1}
  }

elementDimensions: String -> Cmd Events
elementDimensions id =
    Task.attempt
        (\result ->
            case result of
               Ok e -> ServiceAreaElement e
               Err event -> EventError("Could not find dimensions for element")
          )
        (getElement(id))

init : (Model, Cmd Events)
init = (Model(Nothing)([])(False)(outOfView),elementDimensions("service-area"))

handleServiceArea: Element -> Model -> (Model, Cmd Events)
handleServiceArea element model = ({ model | dimensions = element}, Cmd.none)


handleDragStart: PxPosition -> Model -> (Model, Cmd Events)
handleDragStart pxPosition model =
    ({model | ongoingDrag = Just(pxPosition)}, elementDimensions("service-area"))

handleDragStop: Model -> (Model, Cmd Events)
handleDragStop model =
    ({model | ongoingDrag = Nothing}, Cmd.none)

handleMouseMove: PxPosition -> Model -> (Model, Cmd Events)
handleMouseMove pxPosition model =
     let
        inViewPortY = model.dimensions.element.y - model.dimensions.viewport.y > 0
        inViewPortX = model.dimensions.element.x - model.dimensions.viewport.x > 0
        mouseInY    = inViewPortY &&
            model.dimensions.element.y - model.dimensions.viewport.y - pxPosition.y + model.dimensions.element.height > 0
        mouseInX    = inViewPortX &&
            model.dimensions.element.x - model.dimensions.viewport.x - pxPosition.x + model.dimensions.element.width > 0
        newModelWHover = {model | hover = mouseInX && mouseInY}
        newModelWPosition = {newModelWHover | ongoingDrag = Just(pxPosition)}
    in
    Debug.log(Debug.toString(newModelWPosition))
    (newModelWPosition, Cmd.none)



subscriptions: Model -> Sub Events
subscriptions model =
       Maybe.map
        (\_ -> Sub.batch [onMouseMove decodeMousePosition, onMouseUp decodeMouseUp])
        (model.ongoingDrag)
        |> Maybe.withDefault Sub.none



render: Model -> Html Events
render model = div[
    id "service-area",
    class "running-services"
    ][text(Debug.toString(model.hover))]


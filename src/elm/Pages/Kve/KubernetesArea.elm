module Pages.Kve.KubernetesArea exposing (..)
import Html exposing (Html,div)
import Html.Attributes exposing (class,id, style)
import Pages.Kve.Event.KveEvents exposing (KubAreaEvents(..))
import Model.PxPosition as PxPosition
import Model.PxDimensions as PxDimensions
import Pages.Kve.Model.KveModel exposing (ServiceTemplate, NewService, RegisteredService)
import Browser.Dom exposing (Element)
import Browser.Dom exposing (getElement, Element)
import Task
import Html exposing (Html,div,img)
import Html.Attributes exposing (class, src, draggable)
import Html.Events exposing (stopPropagationOn)
import Json.Decode as Json exposing (..)
import Model.PxPosition exposing (PxPosition)
import Browser.Events exposing (onMouseMove,onMouseUp)
import Pages.Kve.Decoder.Mouse as Mouse
import Json.Decode as Decode
import Time


type alias Dragging = {
    service: RegisteredService,
    element: Element
 }
type alias Model = {
    services: List RegisteredService,
    drag: Maybe Dragging
 }

withService: RegisteredService -> Model -> Model
withService service model =
    {model | services = (service :: model.services)}

withServices: List RegisteredService -> Model -> Model
withServices newServices model =
    {model | services = (newServices ++ model.services)}

startDrag: RegisteredService -> PxPosition -> Cmd KubAreaEvents
startDrag registeredService pxPosition =
    getElement("kubernetes-service-area")
    |> Task.attempt  (\r ->
      r
      |> Result.toMaybe
      |> Maybe.map (\elem -> KaStart registeredService pxPosition elem)
      |> Maybe.withDefault (KubernetesError "Could not find element")
    )
dragStopped: RegisteredService -> PxPosition -> Model -> Model
dragStopped _ _ model =
    {model | drag = Nothing}


withNewDrag: RegisteredService -> PxPosition -> Element -> Model -> Model
withNewDrag registeredService _ element model =
    {model | drag = Just (Dragging(registeredService)(element))}

withUpdatedService: {old: RegisteredService, new: RegisteredService} -> Model -> Model
withUpdatedService update model =
    {model | services = Debug.log("New Service")(update.new) :: (model.services |> List.filter (\s -> s.id /= update.old.id))}

withMovedService: RegisteredService -> PxPosition -> Element -> Model -> Model
withMovedService registeredService pxPosition element model =
    let
      newService = {registeredService | position = PxPosition.relativePosition(pxPosition)(element)}
      withOutSer = model.services |> List.filter (\s -> s.id /= registeredService.id)
    in
      {model | services = newService :: withOutSer}


dropService: ServiceTemplate -> PxPosition.PxPosition -> PxDimensions.PxDimensions -> Cmd KubAreaEvents
dropService service pxPosition pxDimensions =
    getElement("kubernetes-service-area")
    |> Task.mapError (\_ -> "")
    |> Task.attempt (\r ->
        r
        |> Result.toMaybe
        |> Maybe.map (\elem ->
            (PxPosition.relativePosition(pxPosition)(elem), PxPosition.relativeBound(elem))
        )
        |> Maybe.map (\posAndBound ->
            let
                (position, bound) = posAndBound
                containsX = position.x > 0 && position.x < bound.x
                containsY = position.y > 0 && position.y < bound.y
            in (
             if (containsX && containsY) then
               KaAdd(NewService(service.id)(service.kind)(position)(pxDimensions))
             else
               KaReject service
             )
        )
        |> Maybe.withDefault (KubernetesError "Could not find element")
    )



subscriptions: (KubAreaEvents -> event) -> Model -> Sub event
subscriptions mapping model =
    model.drag
        |> Maybe.map (\drag -> [
            onMouseMove (Mouse.decodeMousePosition |> Decode.map (subscriptionMapper(drag)) |> Decode.map mapping),
            onMouseUp (Mouse.decodeMouseUp |> Decode.map (subscriptionMapper(drag)) |> Decode.map mapping)]
        )
        |> Maybe.withDefault []
        |> Sub.batch


render: (KubAreaEvents -> event) -> Model -> Html event
render mapper model = div[
    id "kubernetes-service-area",
    class "kubernetes-service-area"
    ]
     (model.services
        |> List.map (\service ->
            div[
                class "kubernetes-service-container",
                style "width" (service.dimensions.width |> PxDimensions.toPxlStr),
                style "height" (service.dimensions.height |> PxDimensions.toPxlStr),
                style "transform" ( service.position |>  PxPosition.centered(service.dimensions) |> PxPosition.toTranslateStr )
            ][renderRegisteredService(service)]
    )
    )
    |> Html.map mapper

-----
renderRegisteredService: RegisteredService -> Html KubAreaEvents
renderRegisteredService service = div[
    class  "kubernetes-service"
    ][img[
        src ("https://robohash.org/" ++ service.name ++ ".png"),
        stopPropagationOn "mousedown" (decodeServiceSelected(service)),
        draggable "false"
        ][]]


decodeServiceSelected: RegisteredService -> (Json.Decoder (KubAreaEvents, Bool))
decodeServiceSelected service =
    Json.map2
     (\x y -> (KaSelected(service)(PxPosition(x)(y)), True))
     (field "pageX" float)
     (field "pageY" float)

subscriptionMapper: Dragging -> Mouse.Event -> KubAreaEvents
subscriptionMapper drag dragEvents  =
 case dragEvents of
     Mouse.MouseMove pxPosition -> (KaDragProgress drag.service pxPosition drag.element)
     Mouse.MouseUp pxPosition -> (KaDragStop drag.service pxPosition drag.element)
------




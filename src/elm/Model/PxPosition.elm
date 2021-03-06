module  Model.PxPosition exposing (..)
import Model.PxDimensions exposing (PxDimensions)
import Model.Pixel as Pixel
import Browser.Dom exposing (Element)

type alias Coordinate = Float
type alias PxPosition = {
    x : Coordinate,
    y : Coordinate
 }
type alias AbsolutePosition = {
    x : Coordinate,
    y : Coordinate
 }

toTranslateStr: PxPosition -> String
toTranslateStr p = "translate(" ++ (p.x |> Pixel.toPxStr) ++ "," ++ (p.y |> Pixel.toPxStr) ++ ")"

relativePosition: PxPosition -> Element -> PxPosition
relativePosition pxPosition element =
    let
        squareL = element.element.x - element.viewport.x
        squareT = element.element.y - element.viewport.y
        relativeX = pxPosition.x - squareL
        relativeY = pxPosition.y - squareT
        relativePos = PxPosition(relativeX)(relativeY)

    in
        Debug.log("Relative Position")relativePos

relativeBound: Element -> PxPosition
relativeBound element =
    let
        yBound = element.element.y - element.viewport.y + element.viewport.height
        xBound = element.element.x - element.viewport.x + element.viewport.width
    in
        Debug.log("RelativeBound")(PxPosition(xBound)(yBound))



centered: PxDimensions -> PxPosition -> PxPosition
centered pxDimensions position  =
       PxPosition(position.x - pxDimensions.width/2)(position.y - pxDimensions.height/2)






module Pages.Kve.Event.KveEvents exposing (
    TemplateContainerEvents(..),
    KubAreaEvents(..), HttpEvents(..)
 )

import Pages.Kve.Model.KveModel exposing (ServiceTemplate, RegisteredService,NewService, RegisteredProject)
import Model.PxPosition exposing (PxPosition)
import Model.PxDimensions exposing (PxDimensions)
import Browser.Dom exposing (Element)





type TemplateContainerEvents =
    TcSelected ServiceTemplate PxPosition |
    TcDragStart ServiceTemplate PxPosition PxDimensions |
    TcDragProgress PxPosition |
    TcDragStop PxPosition |
    TemplateContainerError String


type KubAreaEvents =
    KaAdd NewService |
    KaReject ServiceTemplate |
    KaSelected RegisteredService PxPosition |
    KaStart RegisteredService PxPosition Element |
    KaDragProgress RegisteredService PxPosition Element |
    KaDragStop RegisteredService PxPosition Element |
    KubernetesError String

type HttpEvents =
    ServiceUpdated {old: RegisteredService, new: RegisteredService} |
    ServiceUpdateFailed RegisteredService |
    ServiceCreated RegisteredService |
    ServiceCreationFailed NewService |
    ProjectFetched RegisteredProject |
    ProjectFetchedFailed


classDiagram
    class Adventure
    class Scenario
    class AdventureRepository
    class ScenarioLoader
    class MainScreenController
    class MainScreenViewAbstract {
        <<Abstract>>
    }
    class MaterialMainScreenView
    class CupertinoMainScreenView
    class PlatformViewFactory

    MainScreenController --> AdventureRepository : uses
    MainScreenController --> ScenarioLoader : uses
    MainScreenController --> MainScreenViewAbstract : updates
    AdventureRepository ..> Adventure : manages
    AdventureRepository ..> Scenario : uses // <-- Adicionado
    ScenarioLoader ..> Scenario : manages
    MainScreenViewAbstract <|-- MaterialMainScreenView : implements
    MainScreenViewAbstract <|-- CupertinoMainScreenView : implements
    MainScreenViewAbstract o--> MainScreenController : has a // <-- Adicionado
    PlatformViewFactory ..> MainScreenViewAbstract : creates
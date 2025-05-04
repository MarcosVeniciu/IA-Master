# Classe: MainScreenController (Controller)

Orquestra a lógica e o fluxo de dados para a Tela Principal (Main Screen), atuando como intermediário entre o Model/Data Access e a View.

**Diagrama UML (Mermaid):**

```mermaid
classDiagram
    class MainScreenController {
        -AdventureRepository adventureRepo
        -ScenarioLoader scenarioLoader
        -NavigationService navigationService  // Abstração para navegação
        -AppPreferences appPreferences // Para verificar primeiro lançamento (RF-012)

        +List~Adventure~ ongoingAdventures
        +List~Scenario~ availableScenarios
        +bool isLoadingAdventures
        +bool isLoadingScenarios
        +String? scenarioLoadingError // Mensagem de erro (RF-008)
        +bool isFirstLaunch // Flag para RF-012

        +initialize() void // Inicializa e carrega dados
        +loadData() Future~void~ // Busca aventuras e cenários
        +onContinueAdventure(adventureId: String) void // Ação Continuar (RF-004)
        +onStartScenario(scenario: Scenario) void // Ação Iniciar (RF-007)
        +onGoToSubscription() void // Navega para Assinatura (RF-010)
        +onGoToInstructions() void // Navega para Instruções (RF-011)
        -checkFirstLaunch() void // Verifica e age no primeiro lançamento (RF-012, RF-013)
    }
    class AdventureRepository { }
    class ScenarioLoader { }
    class NavigationService { }
    class AppPreferences { }
    class Adventure { }
    class Scenario { }
    <<Abstract>> MainScreenView { }


    MainScreenController --> AdventureRepository : uses >
    MainScreenController --> ScenarioLoader : uses >
    MainScreenController --> NavigationService : uses >
    MainScreenController --> AppPreferences : uses >
    MainScreenController ..> Adventure : manages state >
    MainScreenController ..> Scenario : manages state >
    MainScreenController ..> MainScreenView : updates <

```

**Dependências (Injetadas):**

*   `adventureRepo`: Para buscar/criar `Adventure`.
*   `scenarioLoader`: Para carregar `Scenario`.
*   `navigationService`: Abstração para navegação entre telas.
*   `appPreferences`: Para verificar o primeiro lançamento (RF-012).

**Atributos de Estado (para a View):**

*   `ongoingAdventures`, `availableScenarios`: Listas de dados a serem exibidas.
*   `isLoadingAdventures`, `isLoadingScenarios`: Indicam o estado de carregamento.
*   `scenarioLoadingError`: Mensagem de erro do carregamento de cenários (RF-008).
*   `isFirstLaunch`: Flag para RF-012.

**Métodos:**

*   `initialize()`: Verifica primeiro lançamento e inicia `loadData`.
*   `loadData()`: Busca dados de forma assíncrona e atualiza o estado.
*   `onContinueAdventure(adventureId)`: Delega navegação para `navigationService` (RF-004).
*   `onStartScenario(scenario)`: Usa `adventureRepo` para criar aventura e `navigationService` para navegar (RF-007).
*   `onGoToSubscription()`: Delega navegação para `navigationService` (RF-010).
*   `onGoToInstructions()`: Delega navegação para `navigationService` (RF-011).
*   `checkFirstLaunch()`: Usa `appPreferences` e `navigationService` (RF-012, RF-013).

**Relacionamentos:**

*   Utiliza `AdventureRepository` e `ScenarioLoader` para obter dados.
*   Utiliza `NavigationService` para tratar ações de navegação.
*   Utiliza `AppPreferences` para lógica de primeiro lançamento.
*   Gerencia o estado das listas `ongoingAdventures` e `availableScenarios`.
*   Atualiza a `MainScreenView` com os dados e estados.
*   Recebe eventos da `MainScreenView` (através dos métodos `on...`).
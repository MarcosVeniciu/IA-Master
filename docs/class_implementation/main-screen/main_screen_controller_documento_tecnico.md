# MainScreenController Technical Document

**Date:** 26/04/2025

## Overview

The `MainScreenController` class orchestrates the logic and data flow for the Main Screen. It acts as an intermediary between the Model/Data Access layers (`AdventureRepository`, `ScenarioLoader`) and the View (`MainScreenView`), managing the screen's state and handling user interactions.

## UML Class Diagram

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

## Methods

*   **`initialize()`**
    *   **Signature:** `void initialize()`
    *   **Description:** Initializes the controller. It first checks if this is the first launch of the application using `checkFirstLaunch()` and then proceeds to load the necessary data by calling `loadData()`.
    *   **Algorithmic notes:** Calls `checkFirstLaunch()` followed by `loadData()`.

*   **`loadData()`**
    *   **Signature:** `Future<void> loadData()`
    *   **Description:** Asynchronously fetches ongoing adventures from `AdventureRepository` and available scenarios from `ScenarioLoader`. It updates the `isLoadingAdventures` and `isLoadingScenarios` flags to reflect the loading state and captures any potential errors during scenario loading in `scenarioLoadingError` (RF-008). Updates the `MainScreenView` upon completion or error.
    *   **Algorithmic notes:** Uses `try-catch` blocks to handle potential exceptions, particularly from `ScenarioLoader`. Updates state variables (`ongoingAdventures`, `availableScenarios`, loading flags, error message) and notifies listeners (the View).

*   **`onContinueAdventure(adventureId: String)`**
    *   **Signature:** `void onContinueAdventure(String adventureId)`
    *   **Description:** Triggered when the user selects an ongoing adventure to continue (RF-004). It delegates the navigation logic to the `NavigationService`, providing the `adventureId` to navigate to the correct adventure screen.

*   **`onStartScenario(scenario: Scenario)`**
    *   **Signature:** `void onStartScenario(Scenario scenario)`
    *   **Description:** Triggered when the user chooses to start a new adventure based on a selected scenario (RF-007). It uses the `AdventureRepository` to create a new `Adventure` instance based on the provided `scenario` and then uses the `NavigationService` to navigate the user to the screen for this newly created adventure.

*   **`onGoToSubscription()`**
    *   **Signature:** `void onGoToSubscription()`
    *   **Description:** Handles the user action to navigate to the subscription screen (RF-010). It delegates the navigation task to the `NavigationService`.

*   **`onGoToInstructions()`**
    *   **Signature:** `void onGoToInstructions()`
    *   **Description:** Handles the user action to navigate to the instructions screen (RF-011). It delegates the navigation task to the `NavigationService`.

*   **`checkFirstLaunch()`**
    *   **Signature:** `void checkFirstLaunch()`
    *   **Description:** Checks if it's the first time the application is launched after installation using `AppPreferences` (RF-012). If it is, it sets the `isFirstLaunch` flag. Depending on the requirements (e.g., RF-013), it might trigger navigation to an onboarding or instructions screen via `NavigationService`. It should also update the preference to mark that the first launch sequence has been completed.

## Implementation Details

*   **Dependencies (Injected):**
    *   `AdventureRepository`: Provides methods to access and manipulate `Adventure` data (e.g., fetching ongoing adventures, creating new ones based on scenarios).
    *   `ScenarioLoader`: Responsible for loading the list of available `Scenario` objects, potentially from assets, a database, or a remote source. Handles potential loading errors (RF-008).
    *   `NavigationService`: An abstraction layer for handling navigation between screens. This decouples the controller from specific navigation implementations (like Flutter's Navigator or GoRouter), improving testability and flexibility. Used for all navigation actions (`onContinueAdventure`, `onStartScenario`, `onGoToSubscription`, `onGoToInstructions`).
    *   `AppPreferences`: Used to read and write simple application preferences, specifically to check and store the first launch status (RF-012).

*   **State Attributes (Exposed to the View):**
    *   `ongoingAdventures`: `List<Adventure>` - A list containing adventures the user has started but not yet completed. Displayed in the UI for the user to continue.
    *   `availableScenarios`: `List<Scenario>` - A list of scenarios available for the user to start a new adventure. Displayed in the UI.
    *   `isLoadingAdventures`: `bool` - A flag indicating whether the `ongoingAdventures` list is currently being fetched. Used by the View to show a loading indicator.
    *   `isLoadingScenarios`: `bool` - A flag indicating whether the `availableScenarios` list is currently being loaded. Used by the View to show a loading indicator.
    *   `scenarioLoadingError`: `String?` - Stores an error message if the `ScenarioLoader` fails (RF-008). The View displays this message if it's not null.
    *   `isFirstLaunch`: `bool` - A flag indicating if this is the very first run of the application (RF-012). Primarily used internally by `checkFirstLaunch()` but could potentially influence the View.

## Change History

| Date         | Author        | Description                   |
| :----------- | :------------ | :---------------------------- |
| 26/04/2025   | Roo (AI)      | Initial document generation. |
| 26/04/2025   | Roo (AI)      | Implementação inicial e correções: `getAllAdventures` em vez de `getOngoingAdventures`, refatoração de `onStartScenario` (criação manual de `Adventure` com `uuid`), adição da dependência `uuid`. |

## Implementation History

[ID: MSC-IMPL-001] 26/04/2025 17:36 - Implementação Inicial e Correções
Reason: Estabelecer a funcionalidade base do controlador e corrigir bugs identificados após a implementação inicial.
Changes:
 - Implementação inicial do `MainScreenController`.
 - Correção: Chamada a `getAllAdventures` no lugar de `getOngoingAdventures` em `loadData`.
 - Correção: Refatoração de `onStartScenario` para criar `Adventure` manualmente usando `uuid` e `saveAdventure`.
 - Adição da dependência `uuid` ao `pubspec.yaml`.
 - Impacto: Garante que todas as aventuras sejam carregadas e que novas aventuras sejam criadas corretamente.
Future Modification Guidelines:
 - Manter a lógica de carregamento de dados em `loadData`.
 - Garantir que a criação de novas aventuras em `onStartScenario` permaneça consistente com o modelo `Adventure`.
 - Verificar a necessidade de `uuid` em futuras modificações que envolvam identificadores únicos.
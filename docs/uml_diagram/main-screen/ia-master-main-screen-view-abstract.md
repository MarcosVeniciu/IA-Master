# Classe Abstrata: MainScreenView (View Interface)

Define o contrato para as implementações concretas da View da Tela Principal, garantindo uma interface consistente para o `MainScreenController` e permitindo a troca de implementações de UI (Material/Cupertino).

**Diagrama UML (Mermaid):**

```mermaid
classDiagram
    <<Abstract>> MainScreenView
    class MainScreenView {
        +MainScreenController controller
        +buildUI() Widget // Constrói a UI lendo o estado do controller
    }
    class MainScreenController { }
    class Adventure { }
    class Scenario { }

    MainScreenView o--> MainScreenController : has a
    MainScreenController ..> MainScreenView : updates (triggers rebuild)
    %% A View lê dados de Adventure/Scenario via Controller dentro do buildUI()

```

**Atributos:**

*   `controller`: Referência ao `MainScreenController` associado.

**Métodos Abstratos/Interface:**

*   `buildUI()`: Método principal que as implementações concretas devem fornecer. Este método é responsável por construir a árvore de widgets da interface do usuário específica da plataforma (Material ou Cupertino). Dentro deste método, a implementação acessará o estado atual do `controller` (ex: `controller.ongoingAdventures`, `controller.isLoadingScenarios`, `controller.scenarioLoadingError`) para decidir o que renderizar, incluindo as listas de aventuras e cenários, indicadores de carregamento, e mensagens de erro ou ausência de dados (RF-003, RF-008). Os widgets interativos (botões, etc.) também serão configurados aqui para chamar os métodos `on...` do `controller`.

**Relacionamentos:**

*   Possui uma referência ao `MainScreenController`.
*   É atualizada pelo `MainScreenController`.
*   Define a interface para exibir dados de `Adventure` e `Scenario`.
*   Serve como base para implementações concretas como `MaterialMainScreenView` e `CupertinoMainScreenView`.
*   É instanciada através da `PlatformViewFactory`.
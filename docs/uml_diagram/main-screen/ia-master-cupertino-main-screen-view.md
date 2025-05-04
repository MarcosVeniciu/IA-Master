# Classe: CupertinoMainScreenView (View Implementation - iOS/Cupertino)

Implementação concreta de `MainScreenView` utilizando os widgets e diretrizes de design da Apple (Cupertino no Flutter), destinada principalmente à plataforma iOS.

**Diagrama UML (Mermaid) - Relação:**

```mermaid
classDiagram
    <<Abstract>> MainScreenView { ... }
    class CupertinoMainScreenView {
        +MainScreenController controller
        +buildUI() Widget // Constrói UI com CupertinoPageScaffold, CupertinoNavigationBar, etc.
        %% Outros métodos herdados/implementados de MainScreenView
    }
    class MainScreenController { }

    CupertinoMainScreenView --|> MainScreenView : implements
    CupertinoMainScreenView o--> MainScreenController : has a
```

**Propósito:**

*   Renderizar a interface da Tela Principal com a aparência nativa do iOS (Cupertino).
*   Utilizar widgets como `CupertinoPageScaffold`, `CupertinoNavigationBar`, `CupertinoListTile`, `CupertinoButton`, `CupertinoActivityIndicator`, etc.
*   Implementar o método `buildUI()` definido em `MainScreenView`. Dentro deste método, a classe lerá o estado atual do `controller` (ex: `controller.ongoingAdventures`, `controller.isLoadingScenarios`, `controller.scenarioLoadingError`) para construir a interface apropriada usando widgets Cupertino, exibindo as listas, indicadores de carregamento (`CupertinoActivityIndicator`), ou mensagens de erro/ausência de dados (RF-003, RF-008).
*   Conectar as interações do usuário nos widgets Cupertino (toques em `CupertinoButton` para "Continue", "Start", "Subscription", "Instructions", etc.) aos métodos correspondentes (`on...`) no `MainScreenController` injetado.

**Relacionamentos:**

*   Implementa a interface `MainScreenView`.
*   Contém uma referência ao `MainScreenController`.
*   É criada pela `PlatformViewFactory` quando a plataforma detectada é iOS.
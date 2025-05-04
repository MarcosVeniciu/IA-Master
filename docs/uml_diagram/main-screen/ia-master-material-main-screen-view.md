# Classe: MaterialMainScreenView (View Implementation - Android/Material)

Implementação concreta de `MainScreenView` utilizando os widgets e diretrizes do Material Design 3 (Flutter), destinada principalmente à plataforma Android.

**Diagrama UML (Mermaid) - Relação:**

```mermaid
classDiagram
    <<Abstract>> MainScreenView { ... }
    class MaterialMainScreenView {
        +MainScreenController controller
        +buildUI() Widget // Constrói UI com Scaffold, Card (Material), etc.
        %% Outros métodos herdados/implementados de MainScreenView
    }
    class MainScreenController { }

    MaterialMainScreenView --|> MainScreenView : implements
    MaterialMainScreenView o--> MainScreenController : has a
```

**Propósito:**

*   Renderizar a interface da Tela Principal com a aparência do Material Design.
*   Utilizar widgets como `Scaffold`, `AppBar`, `Card`, `ListView`, `ElevatedButton`, `CircularProgressIndicator`, etc.
*   Implementar o método `buildUI()` definido em `MainScreenView`. Dentro deste método, a classe lerá o estado atual do `controller` (ex: `controller.ongoingAdventures`, `controller.isLoadingScenarios`, `controller.scenarioLoadingError`) para construir a interface apropriada usando widgets Material, exibindo as listas, indicadores de carregamento, ou mensagens de erro/ausência de dados (RF-003, RF-008).
*   Conectar as interações do usuário nos widgets Material (toques em `ElevatedButton` para "Continue", "Start", "Subscription", "Instructions", etc.) aos métodos correspondentes (`on...`) no `MainScreenController` injetado.

**Relacionamentos:**

*   Implementa a interface `MainScreenView`.
*   Contém uma referência ao `MainScreenController`.
*   É criada pela `PlatformViewFactory` quando a plataforma detectada é Android (ou o padrão desejado é Material).
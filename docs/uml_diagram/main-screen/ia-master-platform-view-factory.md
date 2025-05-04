# Classe: PlatformViewFactory (Factory)

Responsável por instanciar a implementação concreta correta da `MainScreenView` com base na plataforma atual (Android/iOS) ou na preferência de design.

**Diagrama UML (Mermaid) - Relação:**

```mermaid
classDiagram
    class PlatformViewFactory {
        +createMainScreenView(controller: MainScreenController) MainScreenView
    }
    class MainScreenController { }
    <<Abstract>> MainScreenView { }
    class MaterialMainScreenView { }
    class CupertinoMainScreenView { }

    PlatformViewFactory ..> MainScreenController : uses >
    PlatformViewFactory ..> MainScreenView : creates >
    PlatformViewFactory ..> MaterialMainScreenView : creates >
    PlatformViewFactory ..> CupertinoMainScreenView : creates >
```

**Propósito:**

*   Abstrair a lógica de decisão sobre qual estilo de UI (Material ou Cupertino) usar para a Tela Principal.
*   Verificar a plataforma atual (usando `Platform.isAndroid`, `Platform.isIOS` do Flutter) ou uma configuração global.
*   Instanciar `MaterialMainScreenView` ou `CupertinoMainScreenView`, injetando a instância do `MainScreenController` necessária.

**Métodos:**

*   `createMainScreenView(controller)`: Retorna uma instância de `MainScreenView` (seja `MaterialMainScreenView` ou `CupertinoMainScreenView`) com o `controller` fornecido.

**Relacionamentos:**

*   Cria instâncias de `MainScreenView` (especificamente `MaterialMainScreenView` ou `CupertinoMainScreenView`).
*   Recebe uma instância de `MainScreenController` para injetar na View criada.
*   Usada no ponto de entrada da tela principal (ex: no Widget principal da rota) para obter a View correta a ser renderizada.
# Plano de Implementação: PlatformViewFactory

## 1. Goals & Scope

*   **Objetivo:** Implementar a classe `PlatformViewFactory` conforme definido no diagrama UML `ia-master-platform-view-factory.md`. Esta classe será responsável por instanciar a View da Tela Principal (`MainScreenView`).
*   **Escopo Atual:**
    *   Criar a classe `PlatformViewFactory`.
    *   Implementar o método estático `createMainScreenView(MainScreenController controller)`.
    *   **Nesta implementação inicial, o método `createMainScreenView` SEMPRE retornará uma instância de `MaterialMainScreenView`, independentemente da plataforma real do dispositivo ou ambiente de execução (como web).** Isso é para facilitar os testes iniciais.
    *   Incluir um comentário `// TODO:` no código para indicar que a lógica de seleção de plataforma (para retornar `CupertinoMainScreenView` em iOS, por exemplo) precisa ser adicionada posteriormente.
*   **Fora do Escopo (Implementação Futura):**
    *   Implementação da lógica de detecção de plataforma (`Platform.isAndroid`, `Platform.isIOS`).
    *   Instanciação condicional de `CupertinoMainScreenView`.
    *   Consideração de configurações de usuário para sobrescrever a seleção de plataforma.

## 2. Inputs & Artifacts

*   **Documentos de Referência:**
    *   Diagrama UML: `docs/uml_diagram/main-screen/ia-master-platform-view-factory.md`
    *   SRS da Tela Principal: `docs/requirements_analysis/ia-master-main-screen-srs.md`
*   **Arquivos de Código Relevantes (Dependências/Tipos):**
    *   `ai_master/lib/controllers/main_screen_controller.dart` (Parâmetro do método)
    *   `ai_master/lib/features/main_screen/view/main_screen_view_abstract.dart` (Tipo de retorno do método)
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart` (Implementação concreta a ser retornada atualmente)
    *   `ai_master/lib/features/main_screen/view/cupertino_main_screen_view.dart` (Implementação concreta a ser considerada futuramente - *pode não existir ainda*)

## 3. Methodology

1.  **Criação do Arquivo:** Criar um novo arquivo chamado `platform_view_factory.dart` no diretório `ai_master/lib/features/main_screen/factory/`. Se o diretório `factory` não existir, ele deve ser criado.
2.  **Definição da Classe:** Definir a classe `PlatformViewFactory` no arquivo criado.
    ```dart
    import 'package:ai_master/controllers/main_screen_controller.dart';
    import 'package:ai_master/features/main_screen/view/main_screen_view_abstract.dart';
    import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
    // import 'package:ai_master/features/main_screen/view/cupertino_main_screen_view.dart'; // Para uso futuro
    // import 'dart:io' show Platform; // Para uso futuro

    class PlatformViewFactory {
      // Construtor privado para evitar instanciação, já que usaremos um método estático.
      PlatformViewFactory._();

      // TODO: Implementar lógica de seleção de plataforma (Android/iOS/Web/Configuração).
      // Atualmente, sempre retorna MaterialMainScreenView para facilitar testes iniciais,
      // especialmente em ambiente web. A lógica real baseada em Platform.isAndroid/isIOS
      // ou configuração do usuário deve ser adicionada posteriormente.
      static MainScreenView createMainScreenView(MainScreenController controller) {
        // Lógica futura:
        // if (Platform.isIOS) {
        //   return CupertinoMainScreenView(controller: controller);
        // }
        // Por enquanto, sempre retorna Material:
        return MaterialMainScreenView(controller: controller);
      }
    }
    ```
3.  **Implementação do Método:** Implementar o método estático `createMainScreenView` conforme o código acima, garantindo que ele receba um `MainScreenController` e retorne uma instância de `MaterialMainScreenView`, passando o `controller` recebido para o construtor da View.
4.  **Adicionar Comentário TODO:** Incluir o comentário `// TODO:` detalhado acima, explicando a limitação atual e a necessidade de implementação futura.
5.  **Importações:** Adicionar as importações necessárias para `MainScreenController`, `MainScreenView`, e `MaterialMainScreenView`. Comentar as importações que serão necessárias no futuro (`CupertinoMainScreenView`, `dart:io`).
6.  **Revisão:** Revisar o código para garantir que ele esteja alinhado com as convenções do Dart e do projeto.

## 4. Deliverables

*   **Arquivo do Plano:** `platform_view_factory_plano_implementacao.md`
*   **Diretório do Plano:** `docs/class_implementation/main-screen/`
*   **Arquivo de Código:** `ai_master/lib/features/main_screen/factory/platform_view_factory.dart`

## 5. Visualization (Diagrama de Classe UML)

```mermaid
classDiagram
    class PlatformViewFactory {
        <<static>> +createMainScreenView(controller: MainScreenController) MainScreenView
    }
    class MainScreenController { }
    <<Abstract>> MainScreenView { }
    class MaterialMainScreenView {
      +MaterialMainScreenView(controller: MainScreenController)
     }
    class CupertinoMainScreenView {
      +CupertinoMainScreenView(controller: MainScreenController)
     }

    PlatformViewFactory ..> MainScreenController : uses >
    PlatformViewFactory ..> MainScreenView : creates >
    PlatformViewFactory ..> MaterialMainScreenView : creates >
    PlatformViewFactory ..> CupertinoMainScreenView : creates >  // Relação futura
```
*Nota: O diagrama foi ligeiramente ajustado para refletir o método estático e os construtores esperados.*

## 6. Risks and Mitigation

*   **Risco 1:** Esquecer de implementar a lógica completa de seleção de plataforma no futuro, deixando o aplicativo apenas com a UI Material em todas as plataformas.
    *   **Mitigação 1:** Adicionar um comentário `// TODO:` claro e descritivo no código fonte da `PlatformViewFactory`.
    *   **Mitigação 2:** Registrar esta pendência em uma ferramenta de gerenciamento de tarefas ou backlog do projeto.
    *   **Mitigação 3:** Documentar explicitamente esta limitação no README do projeto ou na documentação de arquitetura.
*   **Risco 2:** A classe `CupertinoMainScreenView` pode não existir ou estar incompleta quando a lógica de seleção for implementada.
    *   **Mitigação:** A implementação da `CupertinoMainScreenView` deve ser planejada e rastreada como uma tarefa separada, preferencialmente antes ou em paralelo com a atualização da `PlatformViewFactory`.
*   **Risco 3:** A estrutura de diretórios (`factory`) pode não ser a ideal ou consistente com o restante do projeto.
    *   **Mitigação:** Validar a estrutura de diretórios com a equipe ou seguir as convenções estabelecidas para o projeto Flutter.

## 7. Change History

| Date         | Author      | Description of Changes                     |
| :----------- | :---------- | :----------------------------------------- |
| 2025-04-30   | Roo (AI)    | Criação inicial do plano de implementação. |

## 8. Implementation History

| Date         | Author      | Description of Changes                                                                                                                                                              |
| :----------- | :---------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-04-30   | Roo (AI)    | - Criação do arquivo `ai_master/lib/features/main_screen/factory/platform_view_factory.dart`.                                                                                       |
|              |             | - Implementação inicial da classe `PlatformViewFactory` com método estático `createMainScreenView` retornando `MaterialMainScreenView`.                                               |
|              |             | - Refatoração de `MainScreenViewAbstract` para estender `StatefulWidget`.                                                                                                           |
|              |             | - Ajuste de `MaterialMainScreenView` para herdar de `MainScreenViewAbstract` e corrigir chamada do construtor.                                                                        |
|              |             | - Adição de comentário `// TODO:` para lógica de seleção de plataforma futura.                                                                                                      |
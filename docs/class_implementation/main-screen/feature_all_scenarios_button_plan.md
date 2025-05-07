# Plano de Implementação: Botão "Outros Cenários" e Tela Dedicada

**Data:** 2025-05-05

**Autor:** Roo

**Objetivo:** Modificar a seção "Available Scenarios" na tela principal para exibir um número limitado de cenários (5) e adicionar um botão "Outros cenários..." que navega para uma nova tela dedicada a listar todos os cenários disponíveis.

## Arquivos Modificados/Criados:

1.  **`ai_master/lib/features/main_screen/view/material_main_screen_view.dart`**
    *   **Modificações:**
        *   Alterada a lógica dentro de `_buildAvailableScenariosSection` para usar `allScenarios.take(5)` e limitar a exibição inicial.
        *   Adicionada uma verificação `hasMoreScenarios` para determinar se existem mais cenários além do limite inicial.
        *   Modificado o `itemCount` do `GridView.builder` para `displayedScenarios.length + (hasMoreScenarios ? 1 : 0)`.
        *   Adicionada lógica no `itemBuilder` para:
            *   Exibir `AvailableScenarioCard` para os cenários iniciais (`index < displayedScenarios.length`).
            *   Exibir um `InkWell` com um `Card` estilizado ("Outros cenários...") como último item se `hasMoreScenarios` for verdadeiro.
        *   Implementada a navegação no `onTap` do botão "Outros cenários..." para a nova tela `AllScenariosScreen` usando `Navigator.push` e `MaterialPageRoute`.
        *   Adicionados comentários DartDoc detalhando as alterações na lógica de exibição e no botão.
    *   **Importações Adicionadas:**
        *   `import 'package:ai_master/features/all_scenarios/view/all_scenarios_screen.dart';`

2.  **`ai_master/lib/features/all_scenarios/view/all_scenarios_screen.dart`** (Novo Arquivo)
    *   **Criação:**
        *   Criado um novo `ConsumerWidget` chamado `AllScenariosScreen`.
        *   Adicionada uma `AppBar` com o título "Todos os Cenários".
        *   Utilizado `ref.watch(availableScenariosProvider)` para obter a lista completa de cenários.
        *   Implementado `AsyncValue.when` para lidar com os estados de carregamento, erro e dados.
        *   No estado `data`, utilizado `LayoutBuilder` e `GridView.builder` para exibir todos os cenários usando `AvailableScenarioCard` em uma grade responsiva.
        *   Adicionados comentários DartDoc abrangentes para a classe e o método `build`.
    *   **Dependências:**
        *   `flutter/material.dart`, `flutter_riverpod/flutter_riverpod.dart`
        *   `main_screen_providers.dart`, `scenario.dart`, `available_scenario_card.dart`, `main_screen_controller.dart` (temporário).

## Lógica Principal:

*   A tela principal agora busca todos os cenários, mas exibe apenas os 5 primeiros.
*   Se houver mais de 5, um botão é adicionado ao final da grade.
*   O clique no botão navega para a `AllScenariosScreen`.
*   A `AllScenariosScreen` busca novamente (ou reutiliza o estado do provider) todos os cenários e os exibe em uma grade completa.

## Considerações Futuras/TODOs:

*   Refatorar a dependência direta do `MainScreenController` em ambas as telas para usar providers dedicados ou `ref.read` diretamente nas callbacks de ação (`onStartScenario`).
*   Considerar passar a lista `allScenarios` como argumento para `AllScenariosScreen` em vez de fazer o `ref.watch` novamente, para evitar um possível recarregamento desnecessário (embora o cache do Riverpod possa mitigar isso).

## Histórico de Implementação:

*   **2025-05-05:**
    *   Análise do código existente em `material_main_screen_view.dart`.
    *   Modificação da lógica de exibição para limitar cenários e adicionar placeholder do botão.
    *   Criação do arquivo `all_scenarios_screen.dart` com a estrutura básica.
    *   Implementação da navegação do botão para a nova tela.
    *   Adição de comentários DartDoc aos arquivos modificados/criados.
    *   Correção de erros de sintaxe introduzidos pela aplicação de diff.
    *   Criação deste documento de plano/histórico.
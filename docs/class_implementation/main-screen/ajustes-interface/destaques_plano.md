## Plano de Implementação: Ajustes na Seção de Destaque (Main Screen)

**a. Goals & Scope**

*   **Objetivo Principal:** Modificar a seção de destaque na `MaterialMainScreenView` para implementar um design mais imersivo e interativo.
*   **Metas Específicas:**
    1.  Ajustar o layout para ocupar toda a largura da tela e **ocupar toda a altura da tela, estendendo-se até o topo absoluto (ignorando `AppBar` e `SafeArea` superior).**
    2.  Utilizar a imagem `imageBase64` dos 3 primeiros cenários disponíveis como fundo para cada card de destaque.
    3.  Adicionar um overlay escuro semi-transparente sobre a imagem de fundo para garantir a legibilidade do texto.
    4.  Implementar a rotação automática dos cards de destaque a cada 6 segundos.
    5.  Adicionar um indicador de paginação (pontos) **sobre a parte inferior da imagem de destaque** para mostrar o card atual e o total (3).
*   **Fora do Escopo:**
    *   Modificações nas seções "Ongoing Adventures" ou "Available Scenarios".
    *   Alterações na lógica de carregamento de cenários no `MainScreenController` (além de garantir que os 3 primeiros sejam acessíveis).
    *   Mudanças na navegação ao clicar nos botões "Start".

**b. Inputs & Artifacts**

*   **Arquivos Fonte a Modificar:**
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart` (Principal arquivo da UI)
*   **Arquivos Fonte a Consultar/Utilizar:**
*     *   **Nota (Pós-Refatoração 2025-05-02):** A lógica da seção de destaque foi extraída para `ai_master/lib/features/main_screen/widgets/highlight_section_widget.dart`. O arquivo `material_main_screen_view.dart` agora apenas instancia este widget.
    *   `ai_master/lib/controllers/main_screen_controller.dart` (Para obter a lista de cenários)
    *   `ai_master/lib/models/scenario.dart` (Para acessar o campo `imageBase64`)
*   **Documentos de Referência:**
    *   `docs/requirements_analysis/ia-master-main-screen-srs.md` (Requisitos originais)
    *   `docs/uml_diagram/main-screen/ia-master-material-main-screen-view.md` (Estrutura da View)
    *   Arquivos JSON de cenários em `ai_master/assets/scenarios/` (Para verificar dados `imageBase64`)
*   **Recursos Visuais:**
    *   Imagem fornecida pelo usuário mostrando o estado atual.
    *   Especificações de cores para o indicador (Ativo: Verde Claro, Inativo: Cinza Escuro).

**c. Methodology**

1.  **Refatoração da Estrutura da View (`MaterialMainScreenView`):**
    *   Converter o widget principal (ou um ancestral apropriado de `_buildHighlightSection`) para `StatefulWidget` para gerenciar o `PageController` e o `Timer`.
    *   Inicializar um `PageController` no `initState`.
    *   Inicializar um `Timer.periodic` de 6 segundos no `initState` para chamar `_pageController.nextPage` ou `animateToPage`.
    *   Cancelar o `Timer` e fazer `dispose` do `PageController` no método `dispose`.
2.  **Ajuste do Layout (`_buildHighlightSection` e `buildUI`):**
    *   Remover o `SizedBox` que limita a altura da seção de destaque.
    *   Ajustar o `Scaffold` ou usar um `Stack` para permitir que o `PageView` fique posicionado atrás da `AppBar` (pode exigir `extendBodyBehindAppBar: true` no `Scaffold`). **Para estender até o topo absoluto, será necessário envolver o conteúdo principal (ou o `PageView`) com `SafeArea(top: false, ...)` ou ajustar manualmente o padding superior para ignorar a `SafeArea` e a altura da `AppBar`.**
    *   Garantir que o `PageView` ocupe toda a largura **e altura disponíveis**.
3.  **Modificação do Card de Destaque (`_HighlightCard`):**
    *   Adicionar `String? imageBase64` como parâmetro.
    *   Dentro do `Stack` existente:
        *   Adicionar um widget para decodificar e exibir a imagem Base64 como camada de fundo (ex: `Image.memory(base64Decode(imageBase64.split(',').last))`). Incluir tratamento de erro para `imageBase64` nulo ou inválido.
        *   Adicionar um `Container` sobre a imagem com `color: Colors.black.withOpacity(0.4)` (ajustar opacidade conforme necessário) para criar o overlay escuro semi-transparente.
        *   Garantir que o texto e o botão fiquem sobre o overlay.
4.  **Implementação do Indicador de Paginação:**
    *   **Dentro do `Stack` principal da seção de destaque (sobre a imagem/overlay), na parte inferior,** adicionar um widget indicador. Pode ser um `Row` com 3 `Container`s circulares ou usar um pacote como `smooth_page_indicator`. **Posicionar adequadamente usando `Positioned` ou `Align`.**
    *   Vincular o estado do indicador ao `_pageController` (ex: ouvindo `_pageController.page` ou usando o `onPageChanged` do `PageView`).
    *   Aplicar as cores especificadas: Verde Claro para o ponto ativo, Cinza Escuro para os inativos.
5.  **Integração de Dados:**
    *   Em `_buildHighlightSection`, obter os 3 primeiros cenários da lista `controller.availableScenarios`.
    *   Passar o `scenario.imageBase64` para cada `_HighlightCard`.

**d. Deliverables**

*   **Plano de Implementação:** Este documento, salvo como `docs/class_implementation/main-screen/ajustes-interface/destaques_plano.md`.
*   **Código Modificado:** Versão atualizada do arquivo `ai_master/lib/features/main_screen/view/material_main_screen_view.dart` com as alterações implementadas.

**e. Visualization**

*   **Diagrama de Componentes (Visão Simplificada):**

    ```mermaid
    graph TD
        A[MaterialMainScreenView] --> B{_HighlightSection (Stateful)};
        B --> C[PageView];
        B --> D[PageController];
        B --> E[Timer];
        B --> F[PageIndicator];
        C --> G[_HighlightCard];
        A --> H[MainScreenController];
        H --> I[Scenario];
        G -- Reads --> I;
        E -- Controls --> D;
        D -- Controls --> C;
        D -- Updates --> F;
    ```

*   **Diagrama de Sequência (Rotação Automática):**

    ```mermaid
    sequenceDiagram
        participant T as Timer
        participant V as _HighlightSection State
        participant PC as PageController
        participant PV as PageView
        participant PI as PageIndicator

        loop Every 6 seconds
            T->>V: Tick
            V->>PC: nextPage() / animateToPage()
            PC->>PV: Update displayed page
            PV->>V: onPageChanged (optional)
            V->>PI: Update active indicator
        end
    ```

**f. Risks and Mitigation**

*   **Risco:** Performance impactada pela decodificação de imagens Base64 a cada build do card.
    *   **Mitigação:** Decodificar as imagens uma vez e armazenar os `Uint8List` resultantes no estado ou em cache, se necessário. Testar a fluidez da animação do `PageView`.
*   **Risco:** Complexidade no gerenciamento do `Stack` para posicionamento correto sob a `AppBar` transparente.
    *   **Mitigação:** Utilizar `MediaQuery` para obter a altura da `AppBar` e do `StatusBar` e aplicar `Padding` adequado ao conteúdo principal para evitar sobreposição indesejada. Testar em diferentes dispositivos/tamanhos de tela.
*   **Risco:** Timer continua rodando após o widget ser removido da árvore.
    *   **Mitigação:** Assegurar que o `Timer.cancel()` seja chamado no método `dispose` do `StatefulWidget`.

**g. Change History**

| Date         | Author   | Description of Changes |
| :----------- | :------- | :--------------------- |
| 2025-01-05   | Roo (AI) | Initial plan creation. |
| 2025-01-05   | Roo (AI) | Updated plan: Highlight image to extend to screen top, indicators moved over the image. |

**h. Implementation History**

| Date         | Author   | Description of Changes                                                                                                                               |
| :----------- | :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-01-05   | Roo (AI) | Implemented automatic rotation, background images, overlay, and page indicator for the highlight section in `MaterialMainScreenView`. Added `smooth_page_indicator`. |
| 2025-01-05   | Roo (AI) | Refactored `MaterialMainScreenView` layout: Highlight section now extends to screen top (behind AppBar/StatusBar), indicator moved over the highlight image. Adjusted main content padding. |
| 2025-01-05   | Roo (AI) | Refatorado para usar `CustomScrollView` e `SliverAppBar`. Seção de destaque agora rola com o conteúdo e a AppBar é ocultada no scroll. Corrigidos erros de modelo. |
| 2025-02-05   | Roo (AI) | Modificada a `SliverAppBar` para ser fixa (`pinned: true`) e transparente (`backgroundColor: Colors.transparent`, `elevation: 0`). Adicionado `Padding` superior ao `_HighlightCard` para evitar sobreposição do conteúdo pela `AppBar` fixa. Corrigidos erros de sintaxe. |
| 2025-05-02   | Roo (AI) | Refatoração: Extraído `HighlightSectionWidget` (incluindo `_HighlightCard`) para `widgets/highlight_section_widget.dart`. `material_main_screen_view.dart` atualizado para usar o novo widget. |
| 2025-05-02   | Roo (AI) | Corrigido `_HighlightCard` em `highlight_section_widget.dart`: Removido `Padding` superior do `Card` e adicionado `Padding` ao `Column` interno para permitir que a imagem de fundo se estenda sob a `AppBar`. |
---
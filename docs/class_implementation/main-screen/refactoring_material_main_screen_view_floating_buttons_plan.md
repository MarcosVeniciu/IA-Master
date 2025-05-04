# Plano de Refatoração: MaterialMainScreenView - Botões Flutuantes Dinâmicos

**1. Goals & Scope (Objetivos e Escopo)**

*   **Remover:** Eliminar completamente a `SliverAppBar` existente no arquivo `material_main_screen_view.dart`.
*   **Remover Acesso ao Drawer:** Consequentemente, remover o botão de menu (`leading`) e o acesso ao `AppDrawer` a partir desta tela.
*   **Criar Botões Flutuantes:** Implementar três `IconButton`s que ficarão flutuando no canto superior direito da tela.
*   **Ícones:** Os ícones para os botões serão:
    *   `Icons.payment` (para Assinatura)
    *   `Icons.info_outline` (para Instruções)
    *   `Icons.settings` (para Configurações)
*   **Ações:** As ações `onPressed` de cada botão irão disparar a navegação para as rotas correspondentes, replicando a funcionalidade do `Drawer` original:
    *   Assinatura: `Navigator.pushNamed(context, '/subscription');`
    *   Instruções: `Navigator.pushNamed(context, '/instructions');`
    *   Configurações: `Navigator.pushNamed(context, '/settings');`
*   **Posicionamento:** Utilizar um `Stack` envolvendo o conteúdo principal (`CustomScrollView`) e um widget `Positioned` para fixar os botões no canto superior direito (ex: `top: 16.0`, `right: 16.0`).
*   **Layout:** Organizar os três `IconButton`s horizontalmente dentro do `Positioned` usando um `Row`, com espaçamento adequado entre eles.
*   **Comportamento Dinâmico:** Implementar um mecanismo de ocultação/exibição suave dos botões baseado na direção do scroll:
    *   Associar um `ScrollController` ao `CustomScrollView`.
    *   Adicionar um listener ao `ScrollController`.
    *   Ocultar os botões (ex: com `AnimatedOpacity` ou `Visibility` animado) quando o usuário rolar para baixo (`ScrollDirection.reverse`).
    *   Exibir os botões quando o usuário rolar para cima (`ScrollDirection.forward`) ou a rolagem parar no topo.
*   **Sobreposição Visual:** Garantir que os botões flutuantes fiquem visualmente acima de outros elementos da tela, como a `HighlightSectionWidget`.
*   **Preservar Funcionalidades:** Manter a funcionalidade do `RefreshIndicator`.

**2. Inputs & Artifacts (Entradas e Artefatos)**

*   **Arquivo a Modificar:** `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`
*   **Arquivo de Referência:** `ai_master/lib/widgets/app_drawer.dart` (para confirmar ícones e ações `onPressed`)
*   **Requisitos:** Descrição da tarefa original e clarificações subsequentes.

**3. Methodology (Metodologia)**

1.  **Preparar `_MaterialMainScreenViewState`:**
    *   Adicionar um `ScrollController`: `late ScrollController _scrollController;`
    *   Adicionar um estado booleano para visibilidade: `bool _showFloatingButtons = true;`
    *   No método `initState()`:
        *   Inicializar o controller: `_scrollController = ScrollController();`
        *   Adicionar o listener: `_scrollController.addListener(_scrollListener);`
    *   Criar o método `_scrollListener()`:
        ```dart
        void _scrollListener() {
          if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
            if (_showFloatingButtons) {
              setState(() {
                _showFloatingButtons = false;
              });
            }
          } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
            if (!_showFloatingButtons) {
              setState(() {
                _showFloatingButtons = true;
              });
            }
          }
          // Garante que os botões apareçam se o scroll estiver no topo
          if (_scrollController.position.pixels == 0 && !_showFloatingButtons) {
             setState(() {
               _showFloatingButtons = true;
             });
          }
        }
        ```
    *   No método `dispose()`:
        *   Remover o listener: `_scrollController.removeListener(_scrollListener);`
        *   Dispor o controller: `_scrollController.dispose();`
    *   Remover a `GlobalKey<ScaffoldState> _scaffoldKey`, pois não será mais necessária.
2.  **Ajustar o Método `buildUI()`:**
    *   Remover completamente o widget `SliverAppBar` (linhas 82-105).
    *   Remover as propriedades `key: _scaffoldKey` e `drawer: const AppDrawer()` do `Scaffold`.
    *   Envolver o `RefreshIndicator` com um widget `Stack`.
    *   Adicionar o `CustomScrollView` (que estava dentro do `RefreshIndicator`) como o primeiro filho do `Stack`. **Importante:** Associar o `_scrollController` a ele: `controller: _scrollController`.
    *   Adicionar um `Positioned` como segundo filho do `Stack`:
        *   `top: 16.0` (ajustar conforme necessário para o espaçamento desejado da barra de status)
        *   `right: 16.0`
        *   `child:` um widget `AnimatedOpacity` (ou `Visibility` + `AnimatedSwitcher`):
            *   `opacity: _showFloatingButtons ? 1.0 : 0.0`
            *   `duration: const Duration(milliseconds: 300)`
            *   `child:` um `Row`:
                *   `mainAxisAlignment: MainAxisAlignment.end`
                *   `children:`
                    *   `IconButton(icon: const Icon(Icons.payment), tooltip: 'Assinatura', onPressed: () => Navigator.pushNamed(context, '/subscription'))`
                    *   `const SizedBox(width: 8.0)`
                    *   `IconButton(icon: const Icon(Icons.info_outline), tooltip: 'Instruções', onPressed: () => Navigator.pushNamed(context, '/instructions'))`
                    *   `const SizedBox(width: 8.0)`
                    *   `IconButton(icon: const Icon(Icons.settings), tooltip: 'Configurações', onPressed: () => Navigator.pushNamed(context, '/settings'))`
                    *   *(Opcional: Adicionar `style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3))` se houver problemas de contraste)*

**4. Deliverables (Entregáveis)**

*   Arquivo `ai_master/lib/features/main_screen/view/material_main_screen_view.dart` modificado conforme a metodologia.
*   Este plano salvo como: `docs/class_implementation/main-screen/refactoring_material_main_screen_view_floating_buttons_plan.md`

**5. Visualization (Visualização - Mermaid)**

*   **Diagrama de Componentes (Visão Geral):**
    ```mermaid
    graph TD
        A[MaterialMainScreenView] --> B(Stack);
        B --> C[CustomScrollView];
        B --> D(Positioned);
        C --> E[HighlightSectionWidget];
        C --> F[SliverList Content];
        D --> G(AnimatedOpacity);
        G --> H(Row);
        H --> I1[IconButton: Assinatura];
        H --> I2[IconButton: Instruções];
        H --> I3[IconButton: Configurações];
        J(ScrollController) -.-> A;
        A -.-> J;
        J -- Controls Visibility --> G;
        C -- Uses --> J;
        I1 -- Navigates --> K1[/subscription];
        I2 -- Navigates --> K2[/instructions];
        I3 -- Navigates --> K3[/settings];
    ```

*   **Diagrama de Sequência (Ocultação/Exibição):**
    ```mermaid
    sequenceDiagram
        participant User
        participant ScrollView
        participant ScrollController
        participant MaterialMainScreenView
        participant AnimatedOpacity

        User->>ScrollView: Rola para baixo
        ScrollView->>ScrollController: Notifica scroll (direction: reverse)
        ScrollController->>MaterialMainScreenView: Chama _scrollListener
        MaterialMainScreenView->>MaterialMainScreenView: setState(_showFloatingButtons = false)
        MaterialMainScreenView->>AnimatedOpacity: Atualiza opacity para 0.0
        AnimatedOpacity-->>User: Oculta botões suavemente

        User->>ScrollView: Rola para cima
        ScrollView->>ScrollController: Notifica scroll (direction: forward)
        ScrollController->>MaterialMainScreenView: Chama _scrollListener
        MaterialMainScreenView->>MaterialMainScreenView: setState(_showFloatingButtons = true)
        MaterialMainScreenView->>AnimatedOpacity: Atualiza opacity para 1.0
        AnimatedOpacity-->>User: Exibe botões suavemente
    ```

**6. Risks and Mitigation (Riscos e Mitigação)**

*   **Risco:** Contraste insuficiente entre os ícones dos botões flutuantes e o conteúdo da `HighlightSectionWidget`.
    *   **Mitigação:** Testar com diferentes imagens/cores de fundo na seção de destaque. Se necessário, aplicar um fundo semi-transparente aos `IconButton`s (ex: `IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3))`) para melhorar a legibilidade.
*   **Risco:** Animação de ocultação/exibição não fluida ou com comportamento inesperado em scrolls rápidos ou interrupções.
    *   **Mitigação:** Testar em diferentes dispositivos e cenários de uso. Ajustar a lógica do `_scrollListener` ou a `duration` da animação se necessário. Considerar `Visibility` + `AnimatedSwitcher` como alternativa se `AnimatedOpacity` apresentar problemas.
*   **Risco:** As rotas de navegação (`/subscription`, `/instructions`, `/settings`) podem não estar definidas no roteador principal do aplicativo.
    *   **Mitigação:** Verificar a configuração de rotas (geralmente em `main.dart` ou um arquivo de rotas dedicado) e garantir que essas rotas nomeadas existam antes de implementar as ações `onPressed`.

**7. Change History (Histórico de Alterações)**

| Date       | Author | Description of changes                     |
| :--------- | :----- | :----------------------------------------- |
| 2025-05-02 | Roo    | Criação inicial do plano de refatoração. |

**8. Implementation History (Histórico de Implementação)**

| Date       | Author | Description of changes                                                                                                                               |
| :--------- | :----- | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-05-02 | Roo    | - Removida a `SliverAppBar`. <br> - Adicionado `Stack` e `Positioned` para botões flutuantes. <br> - Implementado `ScrollController` e `_scrollListener` para visibilidade dinâmica. <br> - Adicionados `IconButton`s para Assinatura, Instruções e Configurações com `AnimatedOpacity`. <br> - Adicionado import `flutter/rendering.dart`. |

---

**Revisão e Iteração:**

Este é o plano detalhado. Você está satisfeito com ele ou gostaria de fazer alguma alteração ou ajuste em alguma das seções?
# Plano de Implementação: Layout da Imagem de Destaque e AppBar

**1. Objetivos e Escopo**

*   **Objetivo:** Implementar duas variações de layout para a imagem de destaque (hero image) em relação à AppBar na tela `MaterialMainScreenView`.
    *   **Opção 1:** Imagem posicionada *imediatamente abaixo* de uma AppBar padrão (opaca, que pode ocultar ao rolar).
    *   **Opção 2:** Imagem estendendo-se *por trás* de uma AppBar transparente/translúcida (aprimorando o layout atual para garantir que a imagem cubra a área da status bar).
*   **Escopo:**
    *   Modificar `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`.
    *   Modificar `ai_master/lib/features/main_screen/widgets/highlight_section_widget.dart`.
    *   Focar apenas no posicionamento relativo da imagem de destaque e da AppBar.

**2. Entradas e Artefatos**

*   **Arquivos Fonte:**
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`
    *   `ai_master/lib/features/main_screen/widgets/highlight_section_widget.dart`
*   **Documentos de Referência:** Solicitação do usuário, análise do código existente.

**3. Metodologia**

*   **Opção 1: Imagem Abaixo da AppBar Padrão**
    *   **Em `material_main_screen_view.dart`:**
        *   Modificar a `SliverAppBar` (linhas 82-105):
            *   Remover `backgroundColor: Colors.transparent`. Usar a cor padrão do tema ou definir uma cor opaca.
            *   Remover `elevation: 0` (ou ajustar conforme desejado).
            *   Alterar `pinned: true` para `pinned: false` e `floating: true` (AppBar aparece ao rolar para cima).
            *   Ajustar `systemOverlayStyle` para `SystemUiOverlayStyle.dark` (se a AppBar for clara) ou manter `light` (se for escura).
    *   **Em `highlight_section_widget.dart` (`_HighlightCard`):**
        *   Remover o cálculo e aplicação do `topPadding` (linhas 309 e 390), pois o conteúdo não ficará mais sob a AppBar.

*   **Opção 2: Imagem Atrás da AppBar Transparente (Layout Atual Aprimorado)**
    *   **Em `material_main_screen_view.dart`:**
        *   Manter a `SliverAppBar` (linhas 82-105) essencialmente como está (`pinned: true`, `backgroundColor: Colors.transparent`, `elevation: 0`).
        *   Verificar `systemOverlayStyle` (linha 101) para garantir bom contraste dos ícones da status bar sobre as imagens (manter `light` para fundos escuros).
    *   **Em `highlight_section_widget.dart` (`_HighlightCard`):**
        *   Remover o `Card` wrapper (linha 312) para evitar margens/elevação indesejadas. Usar um `Container` ou diretamente o `Stack`.
        *   Garantir que a `Image.memory` (linha 324) ocupe todo o espaço disponível, *incluindo* a área sob a status bar. O `StackFit.expand` e `BoxFit.cover` já ajudam, mas remover o `Card` pode ser crucial.
        *   Manter o `topPadding` (linhas 309 e 390) aplicado *apenas* ao `Padding` do conteúdo (texto e botão) para que *eles* não fiquem sob a AppBar/status bar.

**4. Entregáveis**

*   Código modificado nos arquivos especificados.
*   Este plano salvo como `docs/class_implementation/main-screen/ajustes-interface/hero_image_appbar_layout_plan.md`.

**5. Visualização (Mermaid)**

*   Não aplicável diretamente para ajustes finos de layout.

**6. Riscos e Mitigação**

*   **Risco (Opção 2):** Contraste insuficiente entre a AppBar transparente/ícones da status bar e algumas imagens de fundo.
    *   **Mitigação:**
        1.  Adicionar um leve fundo à `SliverAppBar`: `backgroundColor: Colors.black.withOpacity(0.2)`.
        2.  Adicionar um fundo sutil ao `IconButton` do menu (como no comentário do código original).
        3.  Ajustar o gradiente no `_HighlightCard` para garantir legibilidade do conteúdo.
*   **Risco:** Performance da decodificação Base64.
    *   **Mitigação:** Já mitigado parcialmente com `frameBuilder`. Monitorar se necessário.

**7. Histórico de Mudanças**

| Data       | Autor | Descrição das Mudanças                     |
| :--------- | :---- | :----------------------------------------- |
| 2025-05-02 | Roo   | Criação inicial do plano de implementação. |

**8. Histórico de Implementação**

*   **2025-05-02 (Roo):** Implementada a Opção 2 (Imagem Atrás da AppBar). Removido o `Card` wrapper do `_HighlightCard` em `highlight_section_widget.dart` e adicionado DartDoc explicativo para permitir que a imagem se estenda sob a status bar.
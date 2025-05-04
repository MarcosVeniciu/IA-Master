# Plano de Refatoração: `material_main_screen_view.dart`

**1. Código Alvo:**

*   **Arquivo:** `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`
*   **Linguagem/Framework:** Dart / Flutter
*   **Propósito:** Implementação da view principal da aplicação (`MainScreen`) usando Material Design, exibindo seções de destaque, aventuras em andamento e cenários disponíveis. Atualmente, contém a lógica da view e as definições de múltiplos sub-widgets.

**2. Objetivos Principais:**

*   **Melhorar Legibilidade e Manutenibilidade:** Separar responsabilidades, tornando o arquivo principal (`material_main_screen_view.dart`) mais enxuto e focado na estrutura geral e conexão com o controller, enquanto os detalhes de cada seção ficam em seus próprios arquivos.
*   **Aumentar Reutilização Potencial:** Embora específicos para esta tela, widgets isolados são inerentemente mais fáceis de adaptar ou reutilizar, se necessário no futuro.
*   **Reduzir Complexidade do Arquivo Principal:** Diminuir o tamanho e o acoplamento dentro de `material_main_screen_view.dart`, facilitando o entendimento e futuras modificações.

**3. Áreas de Foco:**

*   **Extração de Widgets Internos:** Focar na extração das classes privadas `_HighlightSectionWidget` (e seu State), `_OngoingAdventureCard`, e `_AvailableScenarioCard` para arquivos separados.
*   **Organização de Arquivos:** Criar uma estrutura de diretórios clara para os widgets extraídos (ex: `lib/features/main_screen/widgets/`).
*   **Gerenciamento de Importações:** Garantir que todas as importações necessárias sejam movidas para os novos arquivos e que o arquivo original importe corretamente os novos widgets.

**4. Áreas Críticas Identificadas:**

*   **Definições dos Widgets:** As definições completas das classes `_HighlightSectionWidget`, `_HighlightSectionWidgetState`, `_OngoingAdventureCard`, e `_AvailableScenarioCard` atualmente residem dentro de `material_main_screen_view.dart`.
*   **Pontos de Uso:** As instanciações desses widgets dentro dos métodos `buildUI`, `_buildOngoingAdventuresSection`, e `_buildAvailableScenariosSection`.
*   **Passagem de Parâmetros:** Garantir que todos os dados necessários (ex: `highlightScenarios`, `adventure`, `scenario`, callbacks como `onStartScenario`, `onTap`) sejam corretamente passados para os construtores dos novos widgets públicos.
*   **Visibilidade:** As classes privadas (`_`) precisam se tornar públicas (removendo o `_`) para serem importadas e usadas em outros arquivos. O estado (`_HighlightSectionWidgetState`) pode permanecer privado se não for acessado externamente.

**5. Passos Sugeridos (Sequenciais):**

1.  **Preparação:**
    *   **Garantir Versionamento:** Certifique-se de que o código atual esteja commitado em um sistema de controle de versão (Git).
    *   **Criar Diretório:** Crie o diretório `ai_master/lib/features/main_screen/widgets/` (ou um local apropriado para widgets compartilhados, se preferir).
2.  **Extração - `HighlightSectionWidget`:**
    *   Crie o arquivo `widgets/highlight_section_widget.dart`.
    *   **Mova** as definições das classes `_HighlightSectionWidget` e `_HighlightSectionWidgetState` para o novo arquivo.
    *   **Renomeie** `_HighlightSectionWidget` para `HighlightSectionWidget` (remova o `_`). Mantenha `_HighlightSectionWidgetState` privado por enquanto.
    *   Adicione as importações necessárias (`flutter/material.dart`, `dart:async`, `models/scenario.dart`, `smooth_page_indicator`, etc.) no topo do novo arquivo.
    *   Verifique se o construtor e os parâmetros (`highlightScenarios`, `onStartScenario`, `isLoading`) estão corretos.
3.  **Extração - `OngoingAdventureCard`:**
    *   Crie o arquivo `widgets/ongoing_adventure_card.dart`.
    *   **Mova** a definição da classe `_OngoingAdventureCard` para o novo arquivo.
    *   **Renomeie** para `OngoingAdventureCard`.
    *   Adicione as importações (`flutter/material.dart`, `models/adventure.dart`, `intl/intl.dart`).
    *   Verifique o construtor e parâmetros (`adventure`, `onTap`).
4.  **Extração - `AvailableScenarioCard`:**
    *   Crie o arquivo `widgets/available_scenario_card.dart`.
    *   **Mova** a definição da classe `_AvailableScenarioCard` para o novo arquivo.
    *   **Renomeie** para `AvailableScenarioCard`.
    *   Adicione as importações (`flutter/material.dart`, `models/scenario.dart`, `dart:convert`, `dart:typed_data`).
    *   Verifique o construtor e parâmetros (`scenario`, `onStart`).
5.  **Integração e Limpeza em `material_main_screen_view.dart`:**
    *   **Remova** as definições das classes `_HighlightSectionWidget`, `_HighlightSectionWidgetState`, `_OngoingAdventureCard`, e `_AvailableScenarioCard` do arquivo original.
    *   **Adicione** as importações para os três novos arquivos de widget no topo.
    *   **Substitua** as instanciações nos métodos `buildUI`, `_buildOngoingAdventuresSection`, e `_buildAvailableScenariosSection` para usar os nomes das classes públicas (ex: `HighlightSectionWidget(...)`, `OngoingAdventureCard(...)`, `AvailableScenarioCard(...)`).
    *   **Verifique** cuidadosamente se todos os parâmetros estão sendo passados corretamente nas novas instanciações.
    *   Execute `flutter format .` para garantir a formatação.
6.  **Verificação Pós-Refatoração:**
    *   Execute o aplicativo (`flutter run`).
    *   Realize testes manuais completos na `MainScreen`, verificando a exibição e interatividade de todas as seções (destaque, aventuras, cenários).
    *   Execute testes automatizados existentes (widget tests, integration tests) se houver.
7.  **Commit:** Faça um commit das alterações com uma mensagem clara indicando a refatoração realizada.

**6. Técnicas de Refatoração Recomendadas:**

*   **Extract Class:** Principal técnica utilizada para mover as definições dos widgets para seus próprios arquivos/classes.
*   **Move Method / Move Field (Implícito):** Ao extrair a classe, seus métodos e campos associados são movidos junto.
*   **Rename Class:** Alterar nomes de privados (`_`) para públicos.

**7. Ferramentas de Análise/Suporte:**

*   **IDE (VS Code / Android Studio):** Para edição de código, navegação, busca e substituição, e análise estática integrada.
*   **Flutter/Dart Analyzer:** Ferramenta essencial para identificar erros de sintaxe, tipo e importação durante a refatoração.
*   **Flutter Formatter (`flutter format`):** Para manter a consistência do estilo de código.
*   **Sistema de Controle de Versão (Git):** Fundamental para registrar o estado antes da refatoração e commitar as mudanças de forma incremental e segura.

**8. Estratégia de Verificação (Testes):**

*   **Testes Manuais:** Verificação visual e interativa completa da `MainScreen` após a refatoração para garantir que a funcionalidade e a aparência permaneçam inalteradas. Focar em:
    *   Renderização correta das 3 seções.
    *   Rotação automática e manual do destaque.
    *   Cliques nos botões/cards de "Start Scenario" e "Continue Adventure".
    *   Scroll da tela.
    *   Abertura do Drawer.
    *   Comportamento em estados de loading e vazio.
*   **Testes Automatizados:**
    *   **Executar Testes Existentes:** Se houver testes de widget ou integração para a `MainScreen`, executá-los para detectar regressões.
    *   **Considerar Novos Testes:** Esta refatoração pode facilitar a escrita de testes de widget focados nos novos componentes individuais (`HighlightSectionWidget`, `OngoingAdventureCard`, `AvailableScenarioCard`), o que é uma melhoria recomendada.

**9. Métricas de Sucesso:**

*   **Redução de Linhas de Código (LoC):** O arquivo `material_main_screen_view.dart` deve ter uma redução significativa de LoC.
*   **Número de Arquivos:** Aumento do número de arquivos na pasta `widgets` (ou equivalente), indicando maior modularidade (1 arquivo principal se torna 4: 1 view + 3 widgets).
*   **Manutenção da Funcionalidade:** Ausência de regressões funcionais ou visuais confirmada pela estratégia de verificação.
*   **Feedback Qualitativo:** Percepção da equipe (se aplicável) sobre a melhoria na clareza e organização do código.

**10. Restrições:**

*   Nenhuma restrição específica de tempo ou equipe foi mencionada. Assume-se que há tempo suficiente para realizar a refatoração com cuidado e realizar a verificação necessária.

**11. Histórico de Alterações:**

| Data       | Autor       | Descrição das Alterações                     |
| :--------- | :---------- | :------------------------------------------- |
| 2025-05-02 | Roo (AI)    | Criação inicial do plano de refatoração. |
| 2025-05-02 | Roo (AI)    | Execução completa da refatoração conforme o plano. Widgets extraídos e arquivo principal atualizado. |
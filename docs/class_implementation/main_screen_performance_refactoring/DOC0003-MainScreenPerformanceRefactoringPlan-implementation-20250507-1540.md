# Plano de Refatoração: Otimização de Performance da Tela Principal (Exibição de Imagens e Efeitos)

**Data:** 2025-05-07
**Autor:** Roo (IA Architect)
**Documento ID:** DOC0003
**Feature Slug:** main_screen_performance_refactoring

## a. Metas e Escopo

*   **Meta Principal:** Melhorar significativamente a performance de renderização e a fluidez da interface da tela principal, especialmente na lista de "Aventuras em Andamento".
*   **Escopo:**
    1.  Modificar o processo de carregamento de cenários para decodificar imagens Base64 uma única vez durante a splash screen.
    2.  Criar uma nova estrutura de dados (classe wrapper) para encapsular o objeto `Scenario` e seu `Uint8List` de imagem decodificada.
    3.  Atualizar os providers e a UI para utilizar essa nova estrutura de dados.
    4.  Substituir o efeito de `BackdropFilter` (blur) nos cards de aventura por um overlay de cor semi-transparente.
    5.  (Opcional, menor prioridade) Otimizar a busca de cenários na tela principal para O(1) usando um Map.
*   **Fora do Escopo (nesta fase):**
    *   Pré-renderização do efeito de blur na splash screen (conforme decisão de substituir por overlay).
    *   Alterações profundas na lógica de negócios não relacionadas à exibição de imagens ou efeitos visuais.
    *   Otimizações no carregamento da imagem de fundo principal da tela (além de garantir que não seja a causa primária).

## b. Entradas e Artefatos

*   **Arquivos Fonte a Serem Modificados (Principais):**
    *   `ai_master/lib/services/scenario_loader.dart`
    *   `ai_master/lib/features/splash_screen/providers/splash_providers.dart`
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`
    *   `ai_master/lib/features/main_screen/widgets/ongoing_adventure_card.dart`
    *   `ai_master/lib/widgets/blurred_background.dart` (ou sua remoção/substituição)
    *   Um novo arquivo para a classe wrapper (ex: `ai_master/lib/models/scenario_data.dart`)
*   **Documentos de Referência:**
    *   Diagnóstico de performance previamente realizado.
    *   Estrutura atual dos modelos `Scenario` e `Adventure`.

## c. Metodologia (Passos Práticos)

1.  **Criar Classe Wrapper `ScenarioData`:**
    *   Definir uma nova classe, `ScenarioData`.
    *   Esta classe conterá:
        *   `final Scenario scenario;`
        *   `final Uint8List? decodedImageBytes;`
    *   Criar um construtor para esta classe.
    *   Local do arquivo: `ai_master/lib/models/scenario_data.dart` (novo arquivo).

2.  **Modificar `ScenarioLoader`:**
    *   Alterar o método `_parseScenario` (ou `loadScenarios` diretamente) em `ai_master/lib/services/scenario_loader.dart`.
    *   Após `Scenario.fromJson(jsonData)`, se `scenario.imageBase64` não for nulo:
        *   Chamar `ImageUtils.decodeCleanBase64Image(scenario.imageBase64)`.
        *   **Importante:** Mover esta decodificação para um isolate separado usando `compute` do Flutter.
            *   Criar uma função top-level ou estática que receba a string Base64 e retorne `Uint8List?`.
            *   Chamar `await compute(funcaoDeDecodificacao, scenario.imageBase64)`.
        *   Criar uma instância de `ScenarioData` com o `scenario` original e os `decodedImageBytes` resultantes.
    *   O método `loadScenarios` agora retornará `Future<List<ScenarioData>>`.

3.  **Atualizar `splash_providers.dart`:**
    *   Modificar `scenariosLoadProvider` em `ai_master/lib/features/splash_screen/providers/splash_providers.dart` para que seu tipo de retorno seja `FutureProvider<List<ScenarioData>>`.
    *   Ajustar a lógica de `appDataReadyProvider` para esperar por `Future<List<ScenarioData>>`.

4.  **Atualizar `MaterialMainScreenView`:**
    *   Em `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`:
        *   O `scenariosAsyncValue` agora será do tipo `AsyncValue<List<ScenarioData>>`.
        *   Na seção `_buildOngoingAdventuresSection`:
            *   Ao buscar o cenário correspondente, você obterá um objeto `ScenarioData`.
            *   Passar `scenarioData.decodedImageBytes` para o `OngoingAdventureCard`.
            *   Passar `scenarioData.scenario` se precisar de outros dados.
        *   Na seção `_buildAvailableScenariosSection`:
            *   Adaptar para usar `ScenarioData`.
        *   **Otimização Opcional (Busca O(1)):** Transformar `List<ScenarioData>` em `Map<String, ScenarioData>`.

5.  **Modificar `OngoingAdventureCard`:**
    *   Em `ai_master/lib/features/main_screen/widgets/ongoing_adventure_card.dart`:
        *   Alterar o parâmetro `scenarioImageBase64` para `final Uint8List? decodedImageBytes;`.
        *   Remover a chamada para `ImageUtils.decodeCleanBase64Image`.
        *   Passar `decodedImageBytes` diretamente para o widget de imagem.

6.  **Modificar/Substituir `BlurredBackground`:**
    *   Em `ai_master/lib/widgets/blurred_background.dart`:
        *   Remover os parâmetros `sigmaX`, `sigmaY` e o `BackdropFilter`.
        *   O `overlayWidget` (um `Container` com cor semi-transparente) será aplicado sobre a `Image.memory(imageBytes!)`.
        *   O `overlayWidget` será definido no `OngoingAdventureCard`.
        *   Considerar renomear `BlurredBackground` para `ImageWithOverlay` ou similar.

7.  **Modificar `AvailableScenarioCard`:**
    *   Ajustar para receber `ScenarioData` ou `Scenario` e `Uint8List?`.
    *   Aplicar o mesmo overlay de cor semi-transparente.

8.  **Testes e Validação:**
    *   Executar a aplicação e verificar a exibição correta das imagens.
    *   Usar o Flutter DevTools para medir a performance.
    *   Verificar se os logs de decodificação não aparecem mais durante a rolagem.
    *   Confirmar que o tempo de carregamento da splash screen é aceitável.

## d. Entregáveis

*   Código refatorado conforme os passos acima.
*   Um novo arquivo: `ai_master/lib/models/scenario_data.dart`.
*   Relatório de performance comparando antes e depois das otimizações.

## e. Visualização (Mermaid - Fluxo de Dados da Imagem Simplificado Pós-Refatoração)

```mermaid
graph TD
    A[Arquivos JSON de Cenário com imageBase64] --> B(ScenarioLoader);
    B -- Lê e Inicia Decodificação --> C{compute (Isolate)};
    C -- String Base64 --> D[Função de Decodificação Isolada];
    D -- Retorna Uint8List --> C;
    C -- Retorna Uint8List --> B;
    B -- Cria ScenarioData (Scenario + Uint8List) --> E(scenariosLoadProvider);
    E -- Lista de ScenarioData --> F(MaterialMainScreenView);
    F -- Uint8List --> G(OngoingAdventureCard / AvailableScenarioCard);
    G -- Uint8List --> H[Image.memory + Overlay Simples];

    subgraph Splash Screen
        B
        C
        D
        E
    end

    subgraph Tela Principal
        F
        G
        H
    end
```

## f. Riscos e Mitigação

*   **Risco:** Aumento perceptível no tempo de carregamento da splash screen.
    *   **Mitigação:** Uso correto de `compute`; otimizar imagens na origem; feedback de progresso ao usuário.
*   **Risco:** Complexidade na passagem da nova estrutura `ScenarioData`.
    *   **Mitigação:** Planejamento cuidadoso das interfaces dos widgets.
*   **Risco:** Erros na lógica de `compute` ou manipulação de `Uint8List`.
    *   **Mitigação:** Testes unitários e de integração.
*   **Risco:** A mudança visual (remoção do blur) não ser bem aceita.
    *   **Mitigação:** Já confirmado com o usuário.

## g. Histórico de Mudanças (do Plano)

| Data       | Autor | Descrição das mudanças                                                                                                |
| :--------- | :---- | :-------------------------------------------------------------------------------------------------------------------- |
| 2025-05-07 | Roo   | Criação inicial do plano de refatoração.                                                                              |
| 2025-05-07 | Roo   | Ajuste para usar classe wrapper `ScenarioData` em vez de modificar `Scenario`, conforme feedback. Overlay confirmado. |

## h. Histórico de Implementação

| Data       | Autor | Descrição das mudanças                                                                                                                                                                                                                                                           |
| :--------- | :---- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-05-07 | Roo   | Implementados os passos 1-7 do plano: Criação de `ScenarioData`, modificação de `ScenarioLoader` para decodificar imagens em isolate e retornar `List<ScenarioData>`, atualização dos providers, `MaterialMainScreenView`, `OngoingAdventureCard`, `AvailableScenarioCard`, `HighlightSectionWidget` e substituição de `BlurredBackground` por `ImageWithOverlayWidget`. Corrigidos os testes afetados. |

*(Esta seção será preenchida conforme a implementação avança).*
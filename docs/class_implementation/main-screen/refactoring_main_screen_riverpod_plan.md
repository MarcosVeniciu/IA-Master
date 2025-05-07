# Plano de Implementação: Refatoração da MainScreen com Riverpod

**Versão:** 1.0
**Data:** 2025-05-04
**Autor:** Roo (IA Architect)

## 1. Goals & Scope

### 1.1. Goals
*   Refatorar a `MainScreen` (`MaterialMainScreenView` e `MainScreenController`) para utilizar o framework de state management `flutter_riverpod`.
*   Eliminar a condição de corrida inicial na exibição de imagens nos `OngoingAdventureCard`s, garantindo que a UI reaja corretamente aos estados de carregamento, dados e erro das fontes de dados assíncronas.
*   Melhorar a separação de responsabilidades, movendo a lógica de busca de dados e gerenciamento de estado do `MainScreenController` para `Providers` dedicados.
*   Aumentar a testabilidade dos componentes relacionados à tela principal.
*   Simplificar a lógica dentro do widget `MaterialMainScreenView`.

### 1.2. Scope
*   **Arquivos a serem modificados:**
    *   `ai_master/pubspec.yaml` (adição da dependência `flutter_riverpod`)
    *   `ai_master/lib/main.dart` (adição do `ProviderScope`)
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart` (refatoração para `ConsumerWidget` e uso de `ref.watch`)
    *   `ai_master/lib/controllers/main_screen_controller.dart` (remoção/simplificação da lógica de estado e carregamento de dados)
    *   Potencialmente criar um novo arquivo para definir os `Providers` (ex: `ai_master/lib/providers/main_screen_providers.dart`).
*   **Fora do Escopo:**
    *   Alterações em outras telas ou funcionalidades não diretamente ligadas à `MainScreen`.
    *   Mudanças na lógica de negócios dentro dos repositórios (`AdventureRepository`) ou serviços (`ScenarioLoader`).
    *   Implementação de caching (pode ser uma melhoria futura).

## 2. Inputs & Artifacts

*   **Código Fonte Atual:**
    *   `ai_master/lib/controllers/main_screen_controller.dart`
    *   `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`
    *   `ai_master/lib/repositories/adventure_repository.dart`
    *   `ai_master/lib/services/scenario_loader.dart`
    *   `ai_master/lib/main.dart`
*   **Documentos de Referência:**
    *   Análise técnica da condição de corrida e alternativas (fornecida anteriormente).
    *   Documentação oficial do `flutter_riverpod`.

## 3. Methodology

1.  **Adicionar Dependência:** Incluir `flutter_riverpod` na seção `dependencies` do `pubspec.yaml` e executar `flutter pub get`.
2.  **Configurar `ProviderScope`:** Envolver o `MaterialApp` (ou o widget raiz da aplicação) em `main.dart` com um `ProviderScope`.
3.  **Definir Providers Base:**
    *   Criar `Provider`s simples para as instâncias dos repositórios e serviços necessários (ex: `adventureRepositoryProvider`, `scenarioLoaderProvider`). Isso facilita a injeção de dependência e testes.
    *   Considerar a criação de um arquivo dedicado (ex: `lib/providers/main_screen_providers.dart`) para organizar esses providers.
4.  **Criar `FutureProvider`s para Dados Assíncronos:**
    *   Definir `availableScenariosProvider = FutureProvider<List<Scenario>>((ref) => ref.watch(scenarioLoaderProvider).loadScenarios());`
    *   Definir `ongoingAdventuresProvider = FutureProvider<List<Adventure>>((ref) => ref.watch(adventureRepositoryProvider).getAllAdventures());`
5.  **Refatorar `MaterialMainScreenView`:**
    *   Converter `MaterialMainScreenView` de `StatefulWidget` para `ConsumerWidget`. Remover a classe `_MaterialMainScreenViewState`.
    *   No método `build(BuildContext context, WidgetRef ref)`, usar `ref.watch` para observar os `FutureProvider`s:
        *   `final scenariosAsyncValue = ref.watch(availableScenariosProvider);`
        *   `final adventuresAsyncValue = ref.watch(ongoingAdventuresProvider);`
    *   Utilizar o padrão `asyncValue.when(data: ..., loading: ..., error: ...)` para construir a UI de forma reativa aos diferentes estados de cada provider.
        *   Exibir `CircularProgressIndicator` durante o `loading`.
        *   Exibir mensagens de erro apropriadas no estado `error`.
        *   Construir as seções da UI (`HighlightSectionWidget`, `_buildOngoingAdventuresSection`, `_buildAvailableScenariosSection`) no estado `data`, passando os dados carregados (`List<Scenario>` e `List<Adventure>`).
    *   Ajustar a lógica em `_buildOngoingAdventuresSection` para buscar a imagem do cenário: obter a lista de cenários do `scenariosAsyncValue.data` (após garantir que não é nula) e realizar a busca `firstWhereOrNull` dentro do estado `data` de *ambos* os providers.
6.  **Simplificar/Remover `MainScreenController`:**
    *   Remover os atributos de estado (`_ongoingAdventures`, `_availableScenarios`, `_isLoadingAdventures`, `_isLoadingScenarios`, `_scenarioLoadingError`).
    *   Remover os métodos `_setIsLoading...`, `_setOngoing...`, `_setAvailable...`, `_setScenarioLoadingError`.
    *   Remover o método `loadData`.
    *   Remover a necessidade de `ChangeNotifier`.
    *   Manter os métodos que representam *ações* do usuário e lógica de navegação (`onContinueAdventure`, `onStartScenario`, `onGoToSubscription`, `onGoToInstructions`). Estes podem ser chamados diretamente da View, possivelmente passando `ref` ou acessando serviços via providers se necessário. O controller pode se tornar um `Provider` simples ou ser completamente eliminado se as ações forem simples o suficiente para serem gerenciadas diretamente na View ou em providers de ação específicos.
7.  **Testes (Opcional, mas recomendado):**
    *   Escrever testes unitários para os providers.
    *   Escrever testes de widget para a `MaterialMainScreenView`, sobrescrevendo os providers para simular diferentes estados (loading, data, error).

## 4. Deliverables

*   Código fonte modificado nos arquivos listados em "Scope".
*   Potencial novo arquivo: `ai_master/lib/providers/main_screen_providers.dart`.
*   Aplicação funcional com a tela principal utilizando Riverpod para gerenciamento de estado.

## 5. Visualization (Arquitetura Alvo com Riverpod)

```mermaid
graph TD
    subgraph "UI Layer"
        View[MaterialMainScreenView (ConsumerWidget)]
    end

    subgraph "State Management Layer (Riverpod)"
        FP_Scenarios[availableScenariosProvider (FutureProvider)]
        FP_Adventures[ongoingAdventuresProvider (FutureProvider)]
        P_Services[Providers (adventureRepoProvider, scenarioLoaderProvider, etc.)]
    end

    subgraph "Data Layer"
        Repo[AdventureRepository]
        Loader[ScenarioLoader]
        Prefs[AppPreferences]
        DB[DatabaseHelper]
        Assets[AssetBundle]
    end

    subgraph "Navigation"
        NavService[NavigationService]
    end

    View -- ref.watch --> FP_Scenarios;
    View -- ref.watch --> FP_Adventures;
    View -- calls methods --> NavService; %% Ou via um provider de ações
    %% View pode chamar ações no Controller antigo (simplificado) ou diretamente em providers

    FP_Scenarios -- reads --> P_Services;
    FP_Adventures -- reads --> P_Services;

    P_Services -- instantiates/provides --> Repo;
    P_Services -- instantiates/provides --> Loader;
    P_Services -- instantiates/provides --> Prefs;
    P_Services -- instantiates/provides --> NavService;

    Repo -- interacts with --> DB;
    Loader -- interacts with --> Assets;
    Prefs -- interacts with --> SharedPreferences; %% Assumindo SharedPreferencesAppPreferences

    %% Controller antigo (se mantido para ações) poderia ler P_Services
    %% Controller_Simple[MainScreenController (Simplificado)] -- reads --> P_Services;
```

## 6. Risks and Mitigation

| Risco                                       | Probabilidade | Impacto | Mitigação                                                                                                |
| :------------------------------------------ | :------------ | :------ | :------------------------------------------------------------------------------------------------------- |
| Curva de aprendizado do Riverpod            | Média         | Média   | Consultar documentação oficial, seguir exemplos, começar com providers simples e evoluir gradualmente. |
| Complexidade inicial na refatoração         | Média         | Média   | Realizar a refatoração em passos menores e testáveis, focar em uma parte da UI por vez.                  |
| Dificuldade em depurar estados do Riverpod | Baixa         | Média   | Utilizar o Flutter DevTools com o plugin do Riverpod, adicionar logs estratégicos nos providers.         |
| Possíveis regressões na funcionalidade      | Baixa         | Alta    | Realizar testes manuais completos após a refatoração, escrever testes automatizados (widget/unit).       |

## 7. Change History

| Data       | Autor            | Descrição das Mudanças |
| :--------- | :--------------- | :--------------------- |
| 2025-05-04 | Roo (IA Architect) | Criação inicial do plano |

## 8. Implementation History

*(Esta seção será preenchida conforme a implementação progride)*
| 2025-05-04 | Roo (IA Code)    | Implementação completa do plano: Adição do Riverpod, refatoração da View e Controller, criação de Providers, atualização de testes. |
# Plano de Implementação: Imagem de Fundo para Telas Principais

**DOC0002-ScreenBackgrounds-implementation-20250507-1209.md**

## 1. Visão Geral e Objetivos

Este documento detalha o plano para implementar uma imagem de fundo comum nas telas `main-screen` e `all_scenarios_screen` do aplicativo AI Master. O objetivo é melhorar a estética visual e fornecer uma identidade visual consistente nessas seções chave.

**Imagem a ser utilizada:** [`ai_master/assets/images/background.png`](ai_master/assets/images/background.png)

## 2. Escopo

As seguintes telas serão modificadas:

*   **Tela Principal (Material Design):** [`ai_master/lib/features/main_screen/view/material_main_screen_view.dart`](ai_master/lib/features/main_screen/view/material_main_screen_view.dart)
*   **Tela de Todos os Cenários:** [`ai_master/lib/features/all_scenarios/view/all_scenarios_screen.dart`](ai_master/lib/features/all_scenarios/view/all_scenarios_screen.dart)

## 3. Metodologia de Implementação

A imagem de fundo será adicionada utilizando o widget `Stack` em ambas as telas. A imagem será posicionada para preencher toda a área da tela (`Positioned.fill` e `BoxFit.cover`) e ficará atrás do conteúdo principal de cada tela.

### 3.1. Modificações em `ai_master/lib/features/all_scenarios/view/all_scenarios_screen.dart`

O `body` do `Scaffold` existente será envolvido por um widget `Stack`. A `Image.asset` será o primeiro filho do `Stack`, e o conteúdo original (`scenariosAsyncValue.when(...)`) será o segundo.

**Trecho de Código Proposto:**

```dart
// ... outros imports
// import 'package:ai_master/assets/images/background.png'; // Certifique-se que o caminho está correto ou use o caminho relativo no Image.asset

class AllScenariosScreen extends ConsumerWidget {
  // ... construtor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsyncValue = ref.watch(scenariosLoadProvider);
    final controller = MainScreenController(
      adventureRepo: ref.read(adventureRepositoryProvider),
      scenarioLoader: ref.read(scenarioLoaderProvider),
      navigationService: ref.read(navigationServiceProvider),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Cenários'),
        elevation: 1.0,
      ),
      body: Stack( // MODIFICAÇÃO: Adiciona Stack
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Caminho da imagem
              fit: BoxFit.cover,
            ),
          ),
          scenariosAsyncValue.when( // Conteúdo original
            data: (scenarios) {
              // ... (restante do código do data)
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erro ao carregar cenários: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3.2. Modificações em `ai_master/lib/features/main_screen/view/material_main_screen_view.dart`

O `body` do `Scaffold` já utiliza um `Stack`. A `Image.asset` será adicionada como o primeiro filho deste `Stack` existente.

**Trecho de Código Proposto:**

```dart
// ... outros imports
// import 'package:ai_master/assets/images/background.png'; // Certifique-se que o caminho está correto ou use o caminho relativo no Image.asset

class _MaterialMainScreenViewState extends ConsumerState<MaterialMainScreenView> {
  // ... (initState, _scrollListener, dispose)

  @override
  Widget build(BuildContext context) {
    // ... (lógica de providers e controller)
    final double highlightHeight = (MediaQuery.of(context).size.height * 0.4).clamp(250.0, 400.0);

    return Scaffold(
      body: Stack( // Stack existente
        children: [
          Positioned.fill( // MODIFICAÇÃO: Adiciona imagem como primeiro filho
            child: Image.asset(
              'assets/images/background.png', // Caminho da imagem
              fit: BoxFit.cover,
            ),
          ),
          RefreshIndicator(
            // ... (conteúdo original do RefreshIndicator)
          ),
          Positioned(
            // ... (conteúdo original do Positioned para botões flutuantes)
          ),
        ],
      ),
    );
  }
  // ... (restante dos métodos _buildOngoingAdventuresSection, _buildAvailableScenariosSection)
}
```

## 4. Entregáveis

*   Modificações nos arquivos Dart especificados.
*   Este documento de plano de implementação.

## 5. Riscos e Mitigações

*   **Risco:** A imagem de fundo pode tornar o texto ou outros elementos da UI difíceis de ler.
    *   **Mitigação:** A imagem selecionada ([`background.png`](ai_master/assets/images/background.png)) parece ter um contraste adequado. Se problemas de legibilidade surgirem, uma sobreposição translúcida (e.g., `Container` com `Colors.black.withOpacity(0.3)`) pode ser adicionada entre a imagem e o conteúdo principal, ou a imagem pode ser ajustada.
*   **Risco:** Impacto no desempenho devido ao carregamento da imagem.
    *   **Mitigação:** A imagem é um ativo local e o Flutter lida bem com o carregamento de imagens. O uso de `BoxFit.cover` e `Image.asset` é eficiente. Monitorar o desempenho em dispositivos de teste.

## 6. Histórico de Mudanças

| Data       | Autor         | Descrição das Mudanças                                  |
|------------|---------------|---------------------------------------------------------|
| 20250507   | Roo (IA)      | Criação inicial do plano de implementação.              |

## 7. Histórico de Implementação

| 20250507   | Roo (IA)      | Adicionada imagem de fundo em `AllScenariosScreen` e `MaterialMainScreenView` conforme plano. |
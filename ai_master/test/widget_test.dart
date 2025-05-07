import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/scenario_data.dart'; // Importa ScenarioData
// Importa os providers reais que serão sobrescritos
import 'package:ai_master/providers/main_screen_providers.dart';
// Importa o controller apenas se for necessário para testar ações (idealmente não)
// import 'package:ai_master/controllers/main_screen_controller.dart';
// Importa mocks se necessário para dependências do controller (como NavigationService)
// import 'package:mocktail/mocktail.dart';

// --- Mock Data ---
// Define dados de exemplo para usar nos testes
const tScenario = Scenario(
  title: 'Cenário Teste 1',
  author: 'Autor Teste',
  date: '2025-01-01',
  genre: 'Fantasia',
  ambiance: 'Misteriosa',
  imageBase64: null, // Ou uma string base64 válida se quiser testar imagens
  origins: [],
  plots: [],
  scenes: [],
  bankOfIdeas: [],
  rules: [],
  license: 'CC-BY',
  credits: 'Tester',
);

// Cria uma instância de ScenarioData para os testes
final tScenarioData = ScenarioData(
  scenario: tScenario,
  decodedImageBytes:
      null, // Pode ser null para testes de UI que não focam na imagem
);

const tAdventure = Adventure(
  id: 'adv-test-1',
  scenarioTitle: 'Cenário Teste 1',
  adventureTitle: 'Aventura Teste 1',
  gameState: '{}',
  lastPlayedDate: 1678886400000, // Exemplo de timestamp
  progressIndicator: 0.5,
);

// --- Helper para construir o Widget ---
/// Constrói o widget [MaterialMainScreenView] dentro de um [ProviderScope]
/// com os overrides de provider especificados.
Widget buildTestableWidget(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      // Envolve com MaterialApp para fornecer contexto (tema, etc.)
      home: MaterialMainScreenView(),
    ),
  );
}

void main() {
  group('MaterialMainScreenView States', () {
    testWidgets('Shows loading indicators when providers are loading', (
      WidgetTester tester,
    ) async {
      // Arrange: Define overrides para o estado de carregamento
      final overrides = [
        availableScenariosProvider.overrideWith(
          // Retorna um Future que nunca completa para simular loading
          (ref) => Future.delayed(const Duration(days: 1)),
        ),
        ongoingAdventuresProvider.overrideWith(
          // Retorna um Future que nunca completa para simular loading
          (ref) => Future.delayed(const Duration(days: 1)),
        ),
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));

      // Assert: Verifica se os indicadores de progresso são exibidos
      // Pode haver múltiplos, um para cada seção que usa um provider em loading
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Verifica se as mensagens de vazio/erro NÃO são exibidas
      expect(find.textContaining('No adventures started yet'), findsNothing);
      expect(find.textContaining('No scenarios available'), findsNothing);
      expect(find.textContaining('Erro ao carregar'), findsNothing);
    });

    testWidgets('Shows empty state message when adventures list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange: Define overrides com aventuras vazias e cenários com dados
      final overrides = [
        ongoingAdventuresProvider.overrideWith(
          (ref) => Future.value([]), // Retorna Future.value com dados
        ), // Lista vazia
        availableScenariosProvider.overrideWith(
          (ref) => Future.value([
            tScenarioData,
          ]), // Retorna Future.value com ScenarioData
        ), // Cenário de exemplo
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));
      await tester.pumpAndSettle(); // Espera a UI estabilizar

      // Assert: Verifica a mensagem de aventuras vazias
      expect(find.text('Ongoing Adventures'), findsOneWidget);
      expect(find.textContaining('No adventures started yet'), findsOneWidget);
      // Verifica se a seção de cenários disponíveis mostra o cenário
      expect(find.text('Available Scenarios'), findsOneWidget);
      expect(
        find.text(tScenario.title),
        findsOneWidget,
      ); // Verifica o título do cenário
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Shows empty state message when scenarios list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange: Define overrides com cenários vazios e aventuras com dados
      final overrides = [
        availableScenariosProvider.overrideWith(
          (ref) => Future.value([]), // Retorna Future.value com dados
        ), // Lista vazia
        ongoingAdventuresProvider.overrideWith(
          (ref) => Future.value([tAdventure]), // Retorna Future.value com dados
        ), // Aventura de exemplo
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));
      await tester.pumpAndSettle(); // Espera a UI estabilizar

      // Assert: Verifica a mensagem de cenários vazios
      // 1. Destaques (deve mostrar mensagem de vazio se não houver cenários)
      // A lógica exata depende da implementação de HighlightSectionWidget
      // Assumindo que ele mostra algo como 'No highlights'
      expect(
        find.textContaining('Erro ao carregar destaques'),
        findsNothing,
      ); // Garante que não é erro
      // Pode ser necessário ajustar o texto exato esperado para destaques vazios
      // expect(find.text('No highlights available.'), findsOneWidget);

      // 2. Cenários Disponíveis
      expect(find.text('Available Scenarios'), findsOneWidget);
      expect(find.textContaining('No scenarios available'), findsOneWidget);
      // Verifica se a seção de aventuras mostra a aventura
      expect(find.text('Ongoing Adventures'), findsOneWidget);
      expect(
        find.text(tAdventure.adventureTitle),
        findsOneWidget,
      ); // Verifica título da aventura
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Shows data correctly when both providers have data', (
      WidgetTester tester,
    ) async {
      // Arrange: Define overrides com dados para ambos providers
      final overrides = [
        ongoingAdventuresProvider.overrideWith(
          (ref) => Future.value([tAdventure]), // Retorna Future.value com dados
        ),
        availableScenariosProvider.overrideWith(
          (ref) => Future.value([
            tScenarioData,
          ]), // Retorna Future.value com ScenarioData
        ),
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));
      await tester.pumpAndSettle();

      // Assert: Verifica se os dados são exibidos corretamente
      // 1. Destaques (deve mostrar o cenário)
      expect(
        find.text(tScenario.title),
        findsWidgets,
      ); // Pode aparecer no destaque e na lista

      // 2. Aventuras em Andamento
      expect(find.text('Ongoing Adventures'), findsOneWidget);
      expect(find.text(tAdventure.adventureTitle), findsOneWidget);

      // 3. Cenários Disponíveis
      expect(find.text('Available Scenarios'), findsOneWidget);
      // O título do cenário pode aparecer duas vezes (destaque e lista)
      expect(find.text(tScenario.title), findsWidgets);

      // Garante que não há indicadores de loading ou mensagens de vazio/erro
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('No adventures started yet'), findsNothing);
      expect(find.textContaining('No scenarios available'), findsNothing);
      expect(find.textContaining('Erro ao carregar'), findsNothing);
    });

    testWidgets('Shows error message when adventures provider fails', (
      WidgetTester tester,
    ) async {
      // Arrange: Define override de erro para aventuras e dados para cenários
      final testError = Exception('Falha ao carregar aventuras');
      final overrides = [
        ongoingAdventuresProvider.overrideWith(
          // Retorna Future.error
          (ref) => Future.error(testError, StackTrace.current),
        ),
        availableScenariosProvider.overrideWith(
          // Retorna Future.value com dados
          (ref) => Future.value([
            tScenarioData,
          ]), // Retorna Future.value com ScenarioData
        ),
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));
      await tester.pumpAndSettle();

      // Assert: Verifica a mensagem de erro na seção de aventuras
      expect(find.text('Ongoing Adventures'), findsOneWidget);
      expect(
        find.textContaining('Erro ao carregar aventuras:'),
        findsOneWidget,
      );
      // Verifica se a seção de cenários ainda mostra dados
      expect(find.text('Available Scenarios'), findsOneWidget);
      expect(find.text(tScenario.title), findsWidgets); // Destaque e lista
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Shows error message when scenarios provider fails', (
      WidgetTester tester,
    ) async {
      // Arrange: Define override de erro para cenários e dados para aventuras
      final testError = Exception('Falha ao carregar cenários');
      final overrides = [
        availableScenariosProvider.overrideWith(
          // Retorna Future.error
          (ref) => Future.error(testError, StackTrace.current),
        ),
        ongoingAdventuresProvider.overrideWith(
          // Retorna Future.value com dados
          (ref) => Future.value([tAdventure]),
        ),
      ];

      // Act: Constrói o widget
      await tester.pumpWidget(buildTestableWidget(overrides));
      await tester.pumpAndSettle();

      // Assert: Verifica as mensagens de erro
      // 1. Destaques (deve mostrar erro)
      expect(
        find.textContaining('Erro ao carregar destaques:'),
        findsOneWidget,
      );
      // 2. Cenários Disponíveis (deve mostrar erro)
      expect(find.text('Available Scenarios'), findsOneWidget);
      expect(find.textContaining('Erro ao carregar cenários:'), findsOneWidget);
      // Verifica se a seção de aventuras ainda mostra dados
      expect(find.text('Ongoing Adventures'), findsOneWidget);
      expect(find.text(tAdventure.adventureTitle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // TODO: Adicionar testes para interações (onTap nos cards, RefreshIndicator)
    // Isso pode exigir mocks para NavigationService ou providers de ação se
    // as chamadas diretas ao controller forem removidas da View.
  });
}

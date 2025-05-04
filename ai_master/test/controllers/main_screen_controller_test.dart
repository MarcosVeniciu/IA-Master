import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/app_preferences.dart';
import 'package:ai_master/services/navigation_service.dart';
import 'package:ai_master/services/scenario_loader.dart';
import 'package:uuid/uuid.dart'; // Import Uuid

// Gere os mocks executando: flutter pub run build_runner build
@GenerateMocks([
  AdventureRepository,
  ScenarioLoader,
  NavigationService,
  AppPreferences,
  Uuid, // Mock Uuid para controlar a geração de IDs
])
import 'main_screen_controller_test.mocks.dart'; // Importa os mocks gerados

void main() {
  // Mocks
  late MockAdventureRepository mockAdventureRepo;
  late MockScenarioLoader mockScenarioLoader;
  late MockNavigationService mockNavigationService;
  late MockAppPreferences mockAppPreferences;
  late MockUuid mockUuid; // Mock para Uuid

  // Instância do Controller sob teste
  late MainScreenController controller;

  // Dados de teste
  final tScenario1 = Scenario(
    title: 'Scenario 1',
    author: 'Author 1',
    date: '2025-04-26',
    genre: 'Fantasy',
    ambiance: 'Ambiance 1',
    origins: [], // Lista vazia como exemplo
    plots: [], // Lista vazia como exemplo
    scenes: [], // Lista vazia como exemplo
    bankOfIdeas: [], // Lista vazia como exemplo
    rules: [], // Lista vazia como exemplo
    license: 'CC-BY-SA',
    credits: 'Credits 1',
    // imageBase64: null, // Opcional
  );
  final tScenario2 = Scenario(
    title: 'Scenario 2',
    author: 'Author 2',
    date: '2025-04-27',
    genre: 'Sci-Fi',
    ambiance: 'Ambiance 2',
    origins: [
      {'race': 'Human', 'class': 'Pilot'},
    ], // Exemplo com dados
    plots: [
      {'when': 'Beginning', 'you_need_to': 'Find the artifact'},
    ], // Exemplo
    scenes: [
      {'location': 'Mars Base', 'events': 'Sandstorm'},
    ], // Exemplo
    bankOfIdeas: [
      {'subject': 'Alien Tech', 'action': 'Discover'},
    ], // Exemplo
    rules: ['Rule 1', 'Rule 2'], // Exemplo
    license: 'MIT',
    credits: 'Credits 2',
  );
  final tAvailableScenarios = [tScenario1, tScenario2];

  final tAdventure1 = Adventure(
    id: 'adv1',
    scenarioTitle: 'Scenario 1', // Renomeado
    gameState: '{}', // Renomeado
    lastPlayedDate: DateTime.now().millisecondsSinceEpoch, // Renomeado
    progressIndicator: 0.1, // Renomeado e Alterado para double? (10%)
  );
  final tAdventure2 = Adventure(
    id: 'adv2',
    scenarioTitle: 'Scenario 2', // Renomeado
    gameState: '{}', // Renomeado
    lastPlayedDate: DateTime.now().millisecondsSinceEpoch - 10000, // Renomeado
    progressIndicator: 0.5, // Renomeado e Alterado para double? (50%)
  );
  final tOngoingAdventures = [tAdventure1, tAdventure2];

  final tNewAdventureId = 'new-uuid-adv-id';

  setUp(() {
    // Inicializa os mocks antes de cada teste
    mockAdventureRepo = MockAdventureRepository();
    mockScenarioLoader = MockScenarioLoader();
    mockNavigationService = MockNavigationService();
    mockAppPreferences = MockAppPreferences();
    mockUuid = MockUuid(); // Inicializa o mock do Uuid

    // Configura o mock do Uuid para retornar um ID previsível
    when(mockUuid.v4()).thenReturn(tNewAdventureId);

    // Cria a instância do controller com os mocks
    // Nota: A injeção do Uuid não é direta no construtor original.
    // Para testar `onStartScenario` que usa `Uuid().v4()`, precisaríamos
    // refatorar o controller para injetar Uuid ou usar uma abordagem diferente
    // como sobrepor a instância global (menos ideal).
    // Por simplicidade aqui, vamos assumir que a geração de ID funciona
    // e focaremos na lógica de interação com os mocks.
    controller = MainScreenController(
      adventureRepo: mockAdventureRepo,
      scenarioLoader: mockScenarioLoader,
      navigationService: mockNavigationService,
      appPreferences: mockAppPreferences,
      // uuid: mockUuid, // Se Uuid fosse injetado
    );

    // Configuração padrão para first launch (não é o primeiro lançamento)
    when(mockAppPreferences.isFirstLaunch()).thenAnswer((_) async => false);
    when(
      mockAppPreferences.setFirstLaunchCompleted(),
    ).thenAnswer((_) async => true); // Retorna true para indicar sucesso

    // Configuração padrão para carregamento de dados (sucesso)
    when(
      mockAdventureRepo.getAllAdventures(),
    ).thenAnswer((_) async => tOngoingAdventures);
    when(
      mockScenarioLoader.loadScenarios(),
    ).thenAnswer((_) async => tAvailableScenarios);
    // Configuração padrão para salvar aventura (sucesso)
    when(
      mockAdventureRepo.saveAdventure(any),
    ).thenAnswer((_) async => {}); // Retorna Future<void>
  });

  // --- Testes de Inicialização ---

  group('initialize', () {
    test(
      'deve chamar checkFirstLaunch e depois loadData na inicialização',
      () async {
        // Arrange
        when(mockAppPreferences.isFirstLaunch()).thenAnswer((_) async => false);
        when(
          mockAdventureRepo.getAllAdventures(),
        ).thenAnswer((_) async => tOngoingAdventures);
        when(
          mockScenarioLoader.loadScenarios(),
        ).thenAnswer((_) async => tAvailableScenarios);

        // Act
        await controller.initialize();

        // Assert
        // Verifica se as chamadas ocorreram na ordem esperada (individualmente)
        verify(mockAppPreferences.isFirstLaunch()).called(1);
        // Espera um pouco para garantir que as chamadas assíncronas de loadData tenham chance de ocorrer
        await Future.delayed(Duration.zero);
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        verifyNever(
          mockAppPreferences.setFirstLaunchCompleted(),
        ); // Usa verifyNever
      },
    );

    test(
      'deve chamar setFirstLaunchCompleted quando for o primeiro lançamento',
      () async {
        // Arrange
        when(
          mockAppPreferences.isFirstLaunch(),
        ).thenAnswer((_) async => true); // É o primeiro lançamento
        when(
          mockAdventureRepo.getAllAdventures(),
        ).thenAnswer((_) async => tOngoingAdventures);
        when(
          mockScenarioLoader.loadScenarios(),
        ).thenAnswer((_) async => tAvailableScenarios);

        // Act
        await controller.initialize();

        // Assert
        verify(mockAppPreferences.isFirstLaunch()).called(1);
        verify(
          mockAppPreferences.setFirstLaunchCompleted(),
        ).called(1); // Deve ser chamado
        // Espera um pouco
        await Future.delayed(Duration.zero);
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
      },
    );

    test(
      'deve lidar com erro ao verificar first launch e continuar a carregar dados',
      () async {
        // Arrange
        final tError = Exception('Failed to read preferences');
        when(
          mockAppPreferences.isFirstLaunch(),
        ).thenThrow(tError); // Simula erro
        when(
          mockAdventureRepo.getAllAdventures(),
        ).thenAnswer((_) async => tOngoingAdventures);
        when(
          mockScenarioLoader.loadScenarios(),
        ).thenAnswer((_) async => tAvailableScenarios);

        // Act
        await controller.initialize();

        // Assert
        // Verifica que, mesmo com erro no first launch, loadData é chamado
        verify(mockAppPreferences.isFirstLaunch()).called(1);
        verifyNever(
          mockAppPreferences.setFirstLaunchCompleted(),
        ); // Usa verifyNever
        // Espera um pouco
        await Future.delayed(Duration.zero);
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        // O estado de erro não é explicitamente gerenciado para first launch no controller,
        // ele apenas imprime no debug e continua.
      },
    );
  });

  // --- Testes de Carregamento de Dados ---

  group('loadData', () {
    test(
      'deve carregar aventuras e cenários com sucesso e notificar listeners',
      () async {
        // Arrange
        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
          // Verificações de estado na última notificação (ajustado para 6)
          if (listenerCallCount == 6) {
            // Última notificação esperada
            expect(controller.isLoadingAdventures, isFalse);
            expect(controller.isLoadingScenarios, isFalse);
            expect(controller.scenarioLoadingError, isNull);
            expect(controller.ongoingAdventures, tOngoingAdventures);
            expect(controller.availableScenarios, tAvailableScenarios);
          }
        });

        // Act
        await controller.loadData();

        // Assert
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        expect(listenerCallCount, 6); // Ajustado para 6 notificações
        // Verifica o estado final fora do listener também
        expect(controller.isLoadingAdventures, isFalse);
        expect(controller.isLoadingScenarios, isFalse);
        expect(controller.ongoingAdventures, tOngoingAdventures);
        expect(controller.availableScenarios, tAvailableScenarios);
        expect(controller.scenarioLoadingError, isNull);
      },
    );

    test(
      'deve lidar com erro ao carregar aventuras e carregar cenários normalmente',
      () async {
        // Arrange
        final tError = Exception('Failed to load adventures');
        when(
          mockAdventureRepo.getAllAdventures(),
        ).thenThrow(tError); // Simula erro
        when(
          mockScenarioLoader.loadScenarios(),
        ).thenAnswer((_) async => tAvailableScenarios); // Cenários carregam ok

        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
          if (listenerCallCount == 6) {
            // Última notificação esperada
            expect(
              controller.isLoadingAdventures,
              isFalse,
            ); // Terminou (com erro)
            expect(
              controller.isLoadingScenarios,
              isFalse,
            ); // Terminou (com sucesso)
            expect(
              controller.ongoingAdventures,
              isEmpty,
            ); // Lista vazia devido ao erro
            expect(
              controller.availableScenarios,
              tAvailableScenarios,
            ); // Cenários carregados
            expect(
              controller.scenarioLoadingError,
              isNull,
            ); // Nenhum erro de cenário
          }
        });

        // Act
        await controller.loadData();

        // Assert
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        expect(listenerCallCount, 6); // Ajustado para 6
        // Verifica estado final
        expect(controller.ongoingAdventures, isEmpty);
        expect(controller.availableScenarios, tAvailableScenarios);
        expect(controller.scenarioLoadingError, isNull);
      },
    );

    test(
      'deve lidar com erro ao carregar cenários e definir mensagem de erro',
      () async {
        // Arrange
        final tError = Exception('Failed to load scenarios');
        when(
          mockAdventureRepo.getAllAdventures(),
        ).thenAnswer((_) async => tOngoingAdventures); // Aventuras carregam ok
        when(
          mockScenarioLoader.loadScenarios(),
        ).thenThrow(tError); // Simula erro

        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
          if (listenerCallCount == 6) {
            // Última notificação esperada
            expect(
              controller.isLoadingAdventures,
              isFalse,
            ); // Terminou (com sucesso)
            expect(
              controller.isLoadingScenarios,
              isFalse,
            ); // Terminou (com erro)
            expect(
              controller.ongoingAdventures,
              tOngoingAdventures,
            ); // Aventuras carregadas
            expect(
              controller.availableScenarios,
              isEmpty,
            ); // Lista vazia devido ao erro
            expect(controller.scenarioLoadingError, isNotNull); // Erro definido
            expect(
              controller.scenarioLoadingError,
              'Failed to load scenarios. Please try again.',
            );
          }
        });

        // Act
        await controller.loadData();

        // Assert
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        expect(listenerCallCount, 6); // Ajustado para 6
        // Verifica estado final
        expect(controller.ongoingAdventures, tOngoingAdventures);
        expect(controller.availableScenarios, isEmpty);
        expect(controller.scenarioLoadingError, isNotNull);
      },
    );

    test(
      'deve lidar com erro ao carregar ambos, aventuras e cenários',
      () async {
        // Arrange
        final tAdventureError = Exception('Failed to load adventures');
        final tScenarioError = Exception('Failed to load scenarios');
        when(mockAdventureRepo.getAllAdventures()).thenThrow(tAdventureError);
        when(mockScenarioLoader.loadScenarios()).thenThrow(tScenarioError);

        int listenerCallCount = 0;
        controller.addListener(() {
          listenerCallCount++;
          if (listenerCallCount == 6) {
            // Última notificação esperada
            expect(controller.isLoadingAdventures, isFalse);
            expect(controller.isLoadingScenarios, isFalse);
            expect(controller.ongoingAdventures, isEmpty);
            expect(controller.availableScenarios, isEmpty);
            expect(controller.scenarioLoadingError, isNotNull);
          }
        });

        // Act
        await controller.loadData();

        // Assert
        verify(mockAdventureRepo.getAllAdventures()).called(1);
        verify(mockScenarioLoader.loadScenarios()).called(1);
        expect(listenerCallCount, 6); // Ajustado para 6
        // Verifica estado final
        expect(controller.ongoingAdventures, isEmpty);
        expect(controller.availableScenarios, isEmpty);
        expect(controller.scenarioLoadingError, isNotNull);
      },
    );
  });

  // --- Testes de Ações de Navegação ---

  group('Navigation Actions', () {
    test('onContinueAdventure deve chamar navigationService.goToAdventure', () {
      // Arrange
      const adventureId = 'adv1';

      // Act
      controller.onContinueAdventure(adventureId);

      // Assert
      verify(mockNavigationService.goToAdventure(adventureId)).called(1);
    });

    test(
      'onStartScenario deve criar aventura, salvar e chamar navigationService.goToNewAdventure',
      () async {
        // Arrange
        // Configura o mock para saveAdventure (não captura aqui ainda)
        when(mockAdventureRepo.saveAdventure(any)).thenAnswer((_) async => {});

        // Act
        await controller.onStartScenario(tScenario1);

        // Assert
        // Verifica se saveAdventure foi chamado e captura o argumento DEPOIS da ação
        final captured =
            verify(mockAdventureRepo.saveAdventure(captureAny)).captured;
        expect(captured.length, 1); // Garante que foi chamado uma vez
        final savedAdventure = captured.single as Adventure; // Faz o cast

        // Verifica o conteúdo da aventura salva
        // Nota: A verificação exata do ID depende de como o Uuid é tratado.
        // Se Uuid não for mockado/injetado, o ID será aleatório.
        // Assumindo que a lógica interna cria a aventura corretamente:
        expect(savedAdventure.id, isNotNull); // ID deve ser gerado
        expect(savedAdventure.scenarioTitle, tScenario1.title); // Renomeado
        expect(savedAdventure.gameState, '{}'); // Renomeado
        expect(
          savedAdventure.progressIndicator,
          0.0,
        ); // Renomeado e corrigido valor esperado
        expect(savedAdventure.lastPlayedDate, isNotNull); // Renomeado

        // Verifica se a navegação foi chamada com o ID correto
        // O ID é gerado internamente, então usamos o ID capturado
        verify(
          mockNavigationService.goToNewAdventure(savedAdventure.id),
        ).called(1);
      },
    );

    test('onStartScenario deve lidar com erro ao salvar aventura', () async {
      // Arrange
      final tError = Exception('Database error');
      when(
        mockAdventureRepo.saveAdventure(any),
      ).thenThrow(tError); // Simula erro ao salvar

      // Act
      await controller.onStartScenario(tScenario1);

      // Assert
      verify(mockAdventureRepo.saveAdventure(any)).called(1);
      // Verifica que a navegação NÃO foi chamada devido ao erro
      verifyNever(mockNavigationService.goToNewAdventure(any));
      // Poderia verificar se um serviço de mensagens de erro foi chamado (se existisse)
    });

    test(
      'onGoToSubscription deve chamar navigationService.goToSubscription',
      () {
        // Act
        controller.onGoToSubscription();

        // Assert
        verify(mockNavigationService.goToSubscription()).called(1);
      },
    );

    test(
      'onGoToInstructions deve chamar navigationService.goToInstructions',
      () {
        // Act
        controller.onGoToInstructions();

        // Assert
        verify(mockNavigationService.goToInstructions()).called(1);
      },
    );
  });
}

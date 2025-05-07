import 'package:collection/collection.dart'; // Importa para firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Importa para ScrollDirection
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod

// Models
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario_data.dart'; // Importa ScenarioData

// Providers (Agora usando os providers da splash screen para dados pré-carregados)
// import 'package:ai_master/providers/main_screen_providers.dart'; // Removido
import 'package:ai_master/features/splash_screen/providers/splash_providers.dart'; // Adicionado
// Providers de dependência para o controller (mantidos por enquanto)
import 'package:ai_master/providers/main_screen_providers.dart'
    show
        adventureRepositoryProvider,
        scenarioLoaderProvider,
        navigationServiceProvider;

// Widgets
import 'package:ai_master/features/main_screen/widgets/highlight_section_widget.dart';
import 'package:ai_master/features/main_screen/widgets/ongoing_adventure_card.dart';
import 'package:ai_master/features/main_screen/widgets/available_scenario_card.dart';
// Importa a nova tela
import 'package:ai_master/features/all_scenarios/view/all_scenarios_screen.dart';

// Controller (Temporariamente para ações - será refatorado/removido depois)
// TODO: Refatorar ou remover dependência direta do controller para ações
import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:provider/provider.dart'
    as provider; // Usar prefixo para provider

/// A implementação da tela principal (`MainScreen`) usando widgets do Material Design
/// e gerenciamento de estado com Riverpod.
///
/// Exibe as seções de destaque, aventuras em andamento e cenários disponíveis,
/// consumindo dados dos providers Riverpod ([availableScenariosProvider],
/// [ongoingAdventuresProvider]).
class MaterialMainScreenView extends ConsumerStatefulWidget {
  /// Cria uma instância de [MaterialMainScreenView].
  const MaterialMainScreenView({super.key});

  @override
  ConsumerState<MaterialMainScreenView> createState() =>
      _MaterialMainScreenViewState();
}

/// O estado associado a [MaterialMainScreenView].
///
/// Gerencia o [ScrollController] para controlar a visibilidade dos botões flutuantes
/// e constrói a UI principal consumindo os providers Riverpod via `ref`.
class _MaterialMainScreenViewState
    extends ConsumerState<MaterialMainScreenView> {
  /// Controlador para detectar a rolagem da [CustomScrollView].
  late ScrollController _scrollController;

  /// Estado para controlar a visibilidade dos botões flutuantes.
  bool _showFloatingButtons = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // Não há mais necessidade de chamar controller.loadData() aqui,
    // os FutureProviders cuidam disso automaticamente.
  }

  /// Listener para o [ScrollController] que atualiza a visibilidade dos botões.
  void _scrollListener() {
    if (!mounted) return; // Verifica se o estado ainda está montado

    final direction = _scrollController.position.userScrollDirection;
    final pixels = _scrollController.position.pixels;

    if (direction == ScrollDirection.reverse && _showFloatingButtons) {
      setState(() => _showFloatingButtons = false);
    } else if (direction == ScrollDirection.forward && !_showFloatingButtons) {
      setState(() => _showFloatingButtons = true);
    } else if (pixels == 0 && !_showFloatingButtons) {
      // Garante que os botões apareçam no topo
      setState(() => _showFloatingButtons = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Observa os providers de cenários e aventuras.
    /// `ref.watch` reconstrói o widget quando o estado do provider muda.
    final scenariosAsyncValue = ref.watch(
      scenariosLoadProvider,
    ); // Modificado para provider da splash
    final adventuresAsyncValue = ref.watch(
      adventuresLoadProvider,
    ); // Modificado para provider da splash

    // Instancia o controller localmente para usar nas ações.
    // Lê as dependências necessárias dos providers Riverpod.
    // ref.read é usado pois só precisamos da instância, não precisamos ouvir mudanças.
    // NOTA: Isso é uma solução temporária. O ideal seria refatorar as ações
    // para providers dedicados ou usar ref diretamente nas callbacks.
    final controller = MainScreenController(
      adventureRepo: ref.read(adventureRepositoryProvider),
      scenarioLoader: ref.read(scenarioLoaderProvider),
      navigationService: ref.read(navigationServiceProvider),
      // AppPreferences foi removido do construtor do controller
    );

    // Calcula a altura da seção de destaque.
    final double highlightHeight = (MediaQuery.of(context).size.height * 0.4)
        .clamp(250.0, 400.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            // Adiciona imagem como primeiro filho
            child: Image.asset(
              'assets/images/background.png', // Caminho da imagem
              fit: BoxFit.cover,
            ),
          ),

          /// Conteúdo principal rolável com RefreshIndicator.
          /// O RefreshIndicator agora usa os providers para recarregar.
          RefreshIndicator(
            onRefresh: () async {
              // Invalida os providers para forçar o recarregamento.
              ref.invalidate(
                scenariosLoadProvider,
              ); // Modificado para provider da splash
              ref.invalidate(
                adventuresLoadProvider,
              ); // Modificado para provider da splash
              // Espera um pouco para dar tempo aos providers de começarem a carregar
              // ou pode-se esperar pelos FutureProviders completarem se necessário.
              await Future.delayed(const Duration(milliseconds: 100));
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                /// Sliver para a seção de destaque.
                /// Usa `scenariosAsyncValue.when` para lidar com os estados.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: highlightHeight,
                    child: scenariosAsyncValue.when(
                      data: (List<ScenarioData> scenariosDataList) {
                        // Passa a lista de ScenarioData diretamente, pegando os 3 primeiros.
                        final highlightData =
                            scenariosDataList.take(3).toList();
                        return HighlightSectionWidget(
                          highlightScenariosData:
                              highlightData, // Alterado para highlightScenariosData
                          isLoading: false, // Dados carregados
                          // TODO: Refatorar onStartScenario para usar ref.read ou um provider de ação
                          // onStartScenario ainda espera um Scenario, o que é tratado dentro de HighlightSectionWidget
                          onStartScenario: controller.onStartScenario,
                        );
                      },
                      loading:
                          () => HighlightSectionWidget(
                            highlightScenariosData:
                                const [], // Lista vazia de ScenarioData enquanto carrega
                            isLoading: true, // Estado de carregamento
                            onStartScenario:
                                (_) {}, // Não faz nada enquanto carrega
                          ),
                      error:
                          (error, stackTrace) => Center(
                            child: Text(
                              'Erro ao carregar destaques: $error',
                              textAlign: TextAlign.center,
                            ),
                          ),
                    ),
                  ),
                ),

                /// Sliver com padding para as seções de conteúdo.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      // --- Seção de Aventuras em Andamento ---
                      // Passa ambos AsyncValues para lidar com a dependência de cenários
                      _buildOngoingAdventuresSection(
                        adventuresAsyncValue,
                        scenariosAsyncValue,
                        controller,
                      ), // Passa controller temporariamente
                      const SizedBox(height: 24),
                      // --- Seção de Cenários Disponíveis ---
                      _buildAvailableScenariosSection(
                        scenariosAsyncValue,
                        controller,
                      ), // Passa controller temporariamente
                      const SizedBox(height: 16), // Padding inferior
                    ]),
                  ),
                ),
              ],
            ),
          ),

          /// Botões flutuantes posicionados.
          Positioned(
            top:
                16.0 +
                MediaQuery.of(context).padding.top, // Considera a safe area
            right: 16.0,
            child: AnimatedOpacity(
              opacity: _showFloatingButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              // Ignora cliques quando invisível
              child: IgnorePointer(
                ignoring: !_showFloatingButtons,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botões de ação (mantidos por enquanto)
                    // TODO: Refatorar navegação para usar ref.read(navigationServiceProvider)
                    IconButton(
                      icon: const Icon(Icons.payment),
                      tooltip: 'Assinatura',
                      onPressed:
                          () => Navigator.pushNamed(context, '/subscription'),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Instruções',
                      onPressed:
                          () => Navigator.pushNamed(context, '/instructions'),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Configurações',
                      onPressed:
                          () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de aventuras em andamento usando Riverpod.
  ///
  /// Recebe os [AsyncValue]s das aventuras e cenários para lidar com os estados
  /// de carregamento, dados e erro, e para buscar a imagem do cenário correspondente.
  Widget _buildOngoingAdventuresSection(
    AsyncValue<List<Adventure>> adventuresAsyncValue,
    AsyncValue<List<ScenarioData>>
    scenariosDataAsyncValue, // Alterado para ScenarioData
    MainScreenController controller, // Temporário para ação
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ongoing Adventures',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),

        /// Usa `adventuresAsyncValue.when` para construir a UI baseada no estado.
        adventuresAsyncValue.when(
          data: (adventures) {
            // Se não houver aventuras, mostra mensagem.
            if (adventures.isEmpty) {
              return const SizedBox(
                height: 170, // Match card height
                child: Center(
                  child: Text(
                    'No adventures started yet.\nPick one below!',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            // Se houver aventuras, constrói a lista.
            return SizedBox(
              height: 170, // Altura fixa para a lista horizontal
              /// Usa `scenariosDataAsyncValue.when` aninhado para garantir que os cenários
              /// estejam disponíveis para buscar a imagem.
              child: scenariosDataAsyncValue.when(
                data: (List<ScenarioData> scenariosDataList) {
                  // Otimização O(1): Cria um Map para busca rápida de ScenarioData pelo título do cenário.
                  final scenarioDataMap = {
                    for (var data in scenariosDataList)
                      data.scenario.title: data,
                  };

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: adventures.length,
                    itemBuilder: (context, index) {
                      final adventure = adventures[index];
                      // Busca o ScenarioData correspondente usando o Map (O(1)).
                      final stopwatch =
                          Stopwatch()..start(); // Inicia o cronômetro
                      final correspondingScenarioData =
                          scenarioDataMap[adventure.scenarioTitle];
                      stopwatch.stop(); // Para o cronômetro

                      if (correspondingScenarioData != null) {
                        debugPrint(
                          'MaterialMainScreenView: ScenarioData search for "${adventure.scenarioTitle}" took ${stopwatch.elapsedMicroseconds}µs. Found: ${correspondingScenarioData.scenario.title}',
                        );
                      } else {
                        debugPrint(
                          'MaterialMainScreenView: ScenarioData search for "${adventure.scenarioTitle}" took ${stopwatch.elapsedMicroseconds}µs. NOT FOUND.',
                        );
                      }

                      // Usa os bytes decodificados diretamente do ScenarioData.
                      final decodedImageBytes =
                          correspondingScenarioData?.decodedImageBytes;

                      return OngoingAdventureCard(
                        adventure: adventure,
                        // Passa os bytes decodificados em vez da string Base64.
                        // O OngoingAdventureCard precisará ser atualizado para aceitar Uint8List?.
                        decodedImageBytes: decodedImageBytes,
                        // TODO: Refatorar onTap para usar ref.read ou um provider de ação
                        onTap:
                            () => controller.onContinueAdventure(adventure.id),
                      );
                    },
                  );
                },
                // Mostra indicador de carregamento para cenários se as aventuras já carregaram
                loading: () => const Center(child: CircularProgressIndicator()),
                // Mostra erro se o carregamento de cenários falhar
                error: (e, s) => Center(child: Text('Erro cenários: $e')),
              ),
            );
          },
          // Mostra indicador de carregamento enquanto as aventuras carregam.
          loading:
              () => const SizedBox(
                height: 170,
                child: Center(child: CircularProgressIndicator()),
              ),
          // Mostra mensagem de erro se o carregamento de aventuras falhar.
          error:
              (error, stackTrace) => SizedBox(
                height: 170,
                child: Center(
                  child: Text(
                    'Erro ao carregar aventuras: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
      ],
    );
  }

  /// Constrói a seção de cenários disponíveis usando Riverpod.
  ///
  /// Recebe o [AsyncValue] dos cenários para lidar com os estados.
  Widget _buildAvailableScenariosSection(
    AsyncValue<List<ScenarioData>>
    scenariosDataAsyncValue, // Alterado para ScenarioData
    MainScreenController controller, // Temporário para ação
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Scenarios',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),

        /// Usa `scenariosDataAsyncValue.when` para construir a UI.
        scenariosDataAsyncValue.when(
          data: (List<ScenarioData> allScenariosData) {
            /// Define o número máximo de cenários a serem exibidos na grade inicial.
            /// Cenários além deste número serão acessíveis através do botão "Outros cenários".
            const int maxInitialScenarios = 5;

            // Se não houver cenários disponíveis, exibe uma mensagem centralizada.
            if (allScenariosData.isEmpty) {
              return const Center(
                child: Text('No scenarios available at the moment.'),
              );
            }

            /// Cria a lista de ScenarioData que serão exibidos diretamente na grade principal.
            final displayedScenariosData =
                allScenariosData.take(maxInitialScenarios).toList();

            /// Flag para indicar se existem mais cenários do que o limite inicial.
            /// Usado para decidir se o botão "Outros cenários" deve ser exibido.
            final bool hasMoreScenarios =
                allScenariosData.length > maxInitialScenarios;

            // Constrói a grade responsiva usando LayoutBuilder.
            return LayoutBuilder(
              builder: (context, constraints) {
                // Calcula o número de colunas com base na largura da tela.
                int crossAxisCount = 2; // Padrão para telas menores
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4; // Telas largas
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 3; // Telas médias
                }

                // Define a proporção desejada para os cards.
                const double childAspectRatio = 3 / 4;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),

                  /// Define o número total de itens na grade:
                  /// os cenários exibidos + 1 (o botão "Outros") se houver mais cenários.
                  itemCount:
                      displayedScenariosData.length +
                      (hasMoreScenarios ? 1 : 0),
                  itemBuilder: (context, index) {
                    /// Verifica se o índice atual corresponde a um cenário a ser exibido.
                    if (index < displayedScenariosData.length) {
                      final scenarioData = displayedScenariosData[index];

                      /// Retorna o card padrão para o cenário.
                      /// Passa scenarioData.scenario para o card e para a ação.
                      /// O AvailableScenarioCard precisará ser atualizado para aceitar Uint8List?
                      /// e usar scenarioData.decodedImageBytes.
                      return AvailableScenarioCard(
                        scenario: scenarioData.scenario,
                        decodedImageBytes: scenarioData.decodedImageBytes,
                        // TODO: Refatorar onStart para usar ref.read ou um provider de ação
                        onStart:
                            () => controller.onStartScenario(
                              scenarioData.scenario,
                            ),
                      );
                    }
                    /// Se o índice for o último e houver mais cenários, exibe o botão.
                    else {
                      /// Um [InkWell] envolvendo um [Card] estilizado que funciona
                      /// como botão para navegar para a [AllScenariosScreen].
                      return InkWell(
                        onTap: () {
                          /// Ação de navegação ao tocar no botão.
                          /// Usa [Navigator.push] com [MaterialPageRoute] para
                          /// ir para a tela que lista todos os cenários.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllScenariosScreen(),
                            ),
                          );
                        },
                        child: Card(
                          /// Estilo visual para o botão, diferenciando-o dos cards de cenário.
                          /// Usa uma cor secundária com opacidade e uma leve elevação.
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer.withOpacity(0.5),
                          elevation: 2,
                          child: Center(
                            child: Text(
                              'Outros cenários...',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
          // Mostra indicador de carregamento.
          loading: () => const Center(child: CircularProgressIndicator()),
          // Mostra mensagem de erro.
          error:
              (error, stackTrace) => Center(
                child: Text(
                  'Erro ao carregar cenários: $error',
                  textAlign: TextAlign.center,
                ),
              ),
        ),
      ],
    );
  }
}

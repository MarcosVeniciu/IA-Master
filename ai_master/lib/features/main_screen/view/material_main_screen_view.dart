import 'package:collection/collection.dart'; // Importa para firstWhereOrNull
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Importa para ScrollDirection
// import 'package:flutter/services.dart'; // Removido - desnecessário (elementos em material.dart)
import 'package:ai_master/features/main_screen/view/main_screen_view_abstract.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/controllers/main_screen_controller.dart';
// import 'package:ai_master/widgets/app_drawer.dart'; // Removido - não utilizado
import 'package:ai_master/features/main_screen/widgets/highlight_section_widget.dart'; // Importa o widget extraído
import 'package:ai_master/features/main_screen/widgets/ongoing_adventure_card.dart'; // Importa o widget extraído
import 'package:ai_master/features/main_screen/widgets/available_scenario_card.dart'; // Importa o widget extraído

/// A implementação da tela principal (`MainScreen`) usando widgets do Material Design.
///
/// Exibe as seções de destaque, aventuras em andamento e cenários disponíveis,
/// e interage com o [MainScreenController] para obter dados e delegar ações.
/// Utiliza o `provider` para reagir às mudanças de estado no controller.
/// Os widgets das seções foram extraídos para a pasta `widgets/`.
class MaterialMainScreenView extends MainScreenViewAbstract {
  /// Cria uma instância de [MaterialMainScreenView].
  const MaterialMainScreenView({super.key}); // Usa super parâmetro

  @override
  State<MaterialMainScreenView> createState() => _MaterialMainScreenViewState();
}

/// O estado associado a [MaterialMainScreenView].
///
/// Gerencia a construção da UI principal, incluindo a [SliverAppBar] e as seções
/// de conteúdo, delegando a construção de partes específicas para os widgets
/// extraídos ([HighlightSectionWidget], [OngoingAdventureCard], [AvailableScenarioCard]).
class _MaterialMainScreenViewState extends State<MaterialMainScreenView> {
  /// Controlador para detectar a rolagem da [CustomScrollView].
  late ScrollController _scrollController;

  /// Estado para controlar a visibilidade dos botões flutuantes.
  bool _showFloatingButtons = true;

  // A lógica de estado específica das seções foi movida para os widgets correspondentes.

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  /// Listener para o [ScrollController] que atualiza a visibilidade dos botões.
  void _scrollListener() {
    // Verifica a direção do scroll para ocultar/mostrar os botões
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFloatingButtons) {
        // Usa setState para reconstruir a UI com os botões ocultos
        setState(() {
          _showFloatingButtons = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFloatingButtons) {
        // Usa setState para reconstruir a UI com os botões visíveis
        setState(() {
          _showFloatingButtons = true;
        });
      }
    }
    // Garante que os botões sempre apareçam se o scroll estiver no topo
    if (_scrollController.position.pixels == 0 && !_showFloatingButtons) {
      setState(() {
        _showFloatingButtons = true;
      });
    }
  }

  @override
  void dispose() {
    // Remove o listener e dispõe o controller para evitar memory leaks
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O Consumer<MainScreenController> garante que o buildUI é chamado
    // sempre que o controller notifica os ouvintes.
    return buildUI();
  }

  /// Constrói a interface principal da tela usando [CustomScrollView] e [SliverAppBar].
  ///
  /// Esta abordagem permite que a [SliverAppBar] (com o botão de menu) desapareça
  /// durante o scroll e que a seção de destaque role junto com o conteúdo.
  Widget buildUI() {
    // Usa Consumer para ouvir as mudanças no MainScreenController.
    return Consumer<MainScreenController>(
      builder: (context, controller, child) {
        // Calcula a altura desejada para a seção de destaque.
        final double highlightHeight =
            (MediaQuery.of(context).size.height * 0.4).clamp(250.0, 400.0);

        // Obtém os cenários para a seção de destaque.
        final highlightScenarios =
            controller.availableScenarios.take(3).toList();

        // O Scaffold agora não tem mais AppBar nem Drawer.
        return Scaffold(
          // Usa um Stack para colocar os botões flutuantes sobre o conteúdo.
          body: Stack(
            children: [
              // O conteúdo principal rolável.
              RefreshIndicator(
                onRefresh: controller.loadData,
                child: CustomScrollView(
                  controller: _scrollController, // Associa o ScrollController
                  slivers: <Widget>[
                    /// Sliver que contém a seção de destaque.
                    /// Usa o widget extraído [HighlightSectionWidget].
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: highlightHeight, // Define a altura
                        child: HighlightSectionWidget(
                          // <--- Classe pública usada aqui
                          highlightScenarios: highlightScenarios,
                          isLoading: controller.isLoadingScenarios,
                          onStartScenario: controller.onStartScenario,
                        ),
                      ),
                    ),

                    /// Sliver com padding horizontal e que contém as seções de conteúdo.
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 24), // Espaçamento inicial
                          // --- Seção de Aventuras em Andamento ---
                          _buildOngoingAdventuresSection(controller),
                          const SizedBox(
                            height: 24,
                          ), // Espaçamento entre seções
                          // --- Seção de Cenários Disponíveis ---
                          _buildAvailableScenariosSection(controller),
                          const SizedBox(height: 16), // Padding inferior
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              // Botões flutuantes posicionados no canto superior direito.
              Positioned(
                top: 16.0, // Ajuste conforme necessário para a status bar
                right: 16.0,
                child: AnimatedOpacity(
                  opacity: _showFloatingButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TODO: Considerar adicionar um fundo aos botões se o contraste for baixo
                      // style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
                      IconButton(
                        icon: const Icon(Icons.payment),
                        tooltip: 'Assinatura',
                        onPressed: () {
                          // TODO: Garantir que a rota '/subscription' está definida
                          Navigator.pushNamed(context, '/subscription');
                        },
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Instruções',
                        onPressed: () {
                          // TODO: Garantir que a rota '/instructions' está definida
                          Navigator.pushNamed(context, '/instructions');
                        },
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Configurações',
                        onPressed: () {
                          // TODO: Garantir que a rota '/settings' está definida
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói a seção de aventuras em andamento (RF-001.1, RF-002, RF-003).
  ///
  /// Exibe um título e uma lista horizontal de [Adventure]s usando o widget
  /// [OngoingAdventureCard] extraído, ou exibe estados de carregamento/vazio.
  /// Este widget é usado dentro de um [SliverList].
  Widget _buildOngoingAdventuresSection(MainScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ongoing Adventures',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        // Handle Loading State
        if (controller.isLoadingAdventures &&
            controller.ongoingAdventures.isEmpty)
          const SizedBox(
            height: 170, // Match card height
            child: Center(child: CircularProgressIndicator()),
          )
        // Handle Empty State
        else if (controller.ongoingAdventures.isEmpty &&
            !controller.isLoadingAdventures)
          SizedBox(
            height: 170, // Match card height
            child: Center(
              child: Text(
                'No adventures started yet.\nPick one below!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        // Handle Data State
        else
          SizedBox(
            height: 170, // Altura fixa para a lista horizontal
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.ongoingAdventures.length,
              itemBuilder: (context, index) {
                final adventure = controller.ongoingAdventures[index];

                // Encontra o cenário correspondente para obter a imagem
                // Retorna null se não encontrar para evitar erro
                // Usa firstWhereOrNull para simplificar e o nome correto imageBase64
                final correspondingScenario = controller.availableScenarios
                    .firstWhereOrNull(
                      (scenario) =>
                          scenario.title ==
                          adventure.scenarioTitle, // Renomeado
                    );

                // Obtém a imagem base64 (ou null se o cenário não foi encontrado)
                final imageBase64 = correspondingScenario?.imageBase64;

                // Usa o widget extraído OngoingAdventureCard
                return OngoingAdventureCard(
                  // <--- Classe pública usada aqui
                  adventure: adventure,
                  // Passa a imagem base64 (pode ser null)
                  scenarioImageBase64: imageBase64,
                  // Passa o ID da aventura para o controller
                  onTap: () => controller.onContinueAdventure(adventure.id),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Constrói a seção de cenários disponíveis (RF-001.2, RF-004).
  ///
  /// Exibe um título e uma lista vertical de [Scenario]s usando o widget
  /// [AvailableScenarioCard] extraído, ou exibe estados de carregamento/vazio.
  /// Este widget é usado dentro de um [SliverList].
  Widget _buildAvailableScenariosSection(MainScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Scenarios',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        // Handle Loading State
        if (controller.isLoadingScenarios &&
            controller.availableScenarios.isEmpty)
          const Center(child: CircularProgressIndicator())
        // Handle Empty State
        else if (controller.availableScenarios.isEmpty &&
            !controller.isLoadingScenarios)
          Center(
            child: Text(
              'No scenarios available at the moment.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        // Handle Data State
        else
          // Mapeia cada cenário para um card usando o widget extraído
          ...controller.availableScenarios.map((scenario) {
            // Usa o widget extraído AvailableScenarioCard
            return AvailableScenarioCard(
              // <--- Classe pública usada aqui
              scenario: scenario,
              onStart: () => controller.onStartScenario(scenario),
            );
          }), // .toList() removido - desnecessário com spread operator (...)
      ],
    );
  }
}

// As definições das classes _OngoingAdventureCard, _AvailableScenarioCard,
// _HighlightSectionWidget, _HighlightSectionWidgetState e _HighlightCard
// foram movidas para seus próprios arquivos na pasta 'widgets/'.

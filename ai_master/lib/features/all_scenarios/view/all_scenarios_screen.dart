import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
// import 'package:ai_master/providers/main_screen_providers.dart'; // Removido
import 'package:ai_master/features/splash_screen/providers/splash_providers.dart'; // Adicionado
// Providers de dependência para o controller (mantidos por enquanto)
import 'package:ai_master/providers/main_screen_providers.dart'
    show
        adventureRepositoryProvider,
        scenarioLoaderProvider,
        navigationServiceProvider;

// Models
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/scenario_data.dart'; // Importa ScenarioData

// Widgets
import 'package:ai_master/features/main_screen/widgets/available_scenario_card.dart';

// Controller (Temporário para ação - idealmente refatorar)
import 'package:ai_master/controllers/main_screen_controller.dart';

/// {@template all_scenarios_screen}
/// Uma tela dedicada a exibir **todos** os cenários disponíveis para o usuário
/// em uma grade responsiva.
///
/// Esta tela é tipicamente acessada a partir de um link ou botão na tela principal
/// quando há mais cenários do que o exibido inicialmente.
///
/// Utiliza o [availableScenariosProvider] para obter a lista de [Scenario]
/// e o [GridView.builder] para apresentar os [AvailableScenarioCard].
/// {@endtemplate}
class AllScenariosScreen extends ConsumerWidget {
  /// {@macro all_scenarios_screen}
  const AllScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Observa o provider de cenários disponíveis.
    /// O `ref.watch` garante que a tela será reconstruída se a lista de cenários mudar.
    final scenariosAsyncValue = ref.watch(
      scenariosLoadProvider,
    ); // Modificado para provider da splash

    // Lê o controller para a ação de iniciar cenário (solução temporária).
    // O ideal seria ter um provider dedicado para essa ação ou usar ref.read diretamente.
    // TODO: Refatorar para remover a dependência direta do MainScreenController.
    final controller = MainScreenController(
      adventureRepo: ref.read(adventureRepositoryProvider),
      scenarioLoader: ref.read(scenarioLoaderProvider),
      navigationService: ref.read(navigationServiceProvider),
    );

    return Scaffold(
      appBar: AppBar(
        /// Título da AppBar.
        title: const Text('Todos os Cenários'),

        /// Adiciona um leve sombreamento à AppBar para destaque.
        elevation: 1.0,
      ),

      /// O corpo da tela utiliza o `AsyncValue.when` para tratar os diferentes
      /// estados do provider: carregando, erro ou dados disponíveis.
      body: Stack(
        // Adiciona Stack
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Caminho da imagem
              fit: BoxFit.cover,
            ),
          ),
          scenariosAsyncValue.when(
            // Conteúdo original movido para dentro do Stack
            /// Estado de dados: Constrói a grade de cenários.
            data: (List<ScenarioData> scenariosDataList) {
              // Alterado para List<ScenarioData>
              /// Se a lista de cenários estiver vazia, exibe uma mensagem informativa.
              if (scenariosDataList.isEmpty) {
                return const Center(
                  child: Text('Nenhum cenário disponível no momento.'),
                );
              }

              /// Usa [LayoutBuilder] para adaptar o número de colunas da grade
              /// ao tamanho da tela, tornando a UI responsiva.
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula o número de colunas com base na largura da tela.
                  int crossAxisCount = 2; // Padrão para telas menores
                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 4; // Telas largas
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 3; // Telas médias
                  }

                  // Define a proporção desejada para os cards (largura / altura).
                  const double childAspectRatio = 3 / 4;

                  /// Usa [GridView.builder] para exibir os cenários de forma eficiente.
                  /// O [Padding] adiciona espaço ao redor da grade.
                  return GridView.builder(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Padding ao redor da grade
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          crossAxisCount, // Número de colunas dinâmico.
                      childAspectRatio:
                          childAspectRatio, // Proporção fixa dos cards.
                      crossAxisSpacing: 12, // Espaçamento horizontal.
                      mainAxisSpacing: 12, // Espaçamento vertical.
                    ),
                    itemCount:
                        scenariosDataList
                            .length, // Total de cenários a serem exibidos.
                    itemBuilder: (context, index) {
                      final scenarioData =
                          scenariosDataList[index]; // Agora é ScenarioData

                      /// Cria um [AvailableScenarioCard] para cada cenário na lista.
                      return AvailableScenarioCard(
                        scenario:
                            scenarioData.scenario, // Passa o Scenario interno
                        decodedImageBytes:
                            scenarioData
                                .decodedImageBytes, // Passa os bytes da imagem
                        /// Ação ao iniciar o cenário (usando o controller temporário).
                        onStart:
                            () => controller.onStartScenario(
                              scenarioData.scenario,
                            ), // Passa o Scenario interno
                      );
                    },
                  );
                },
              );
            },

            /// Estado de carregamento: Mostra um indicador de progresso centralizado.
            loading: () => const Center(child: CircularProgressIndicator()),

            /// Estado de erro: Mostra uma mensagem de erro centralizada e com padding.
            error:
                (error, stackTrace) => Center(
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

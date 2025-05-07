import 'dart:async'; // Para Timer
import 'dart:typed_data'; // Para Uint8List
import 'dart:ui'; // Para ImageFilter

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importa o indicador de página
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/scenario_data.dart'; // Importa ScenarioData
import 'package:ai_master/utils/image_utils.dart'; // Importa o utilitário de imagem
// Importa o widget renomeado
import 'package:ai_master/widgets/blurred_background.dart'; // Será ImageWithOverlayWidget

/// Um widget stateful dedicado para gerenciar a seção de destaque rotativa.
///
/// Este widget isola o estado do [PageController], [Timer] e índice da página atual,
/// evitando que a atualização do indicador de página cause a reconstrução de toda
/// a view principal. Exibe uma lista de [ScenarioData]s em um [PageView] com
/// navegação automática e manual, utilizando [_HighlightCard] para cada item.
class HighlightSectionWidget extends StatefulWidget {
  /// A lista de dados de cenários (incluindo imagens decodificadas) a serem exibidos como destaque.
  final List<ScenarioData> highlightScenariosData;

  /// Callback chamado quando o botão "Start Scenario" em um destaque é pressionado.
  /// Passa o [Scenario] selecionado como argumento.
  final Function(Scenario) onStartScenario;

  /// Indica se os cenários ainda estão sendo carregados pela view principal.
  /// Usado para exibir um indicador de progresso.
  final bool isLoading;

  /// Cria uma instância de [HighlightSectionWidget].
  ///
  /// Requer [highlightScenariosData], [onStartScenario] e [isLoading].
  const HighlightSectionWidget({
    super.key, // Usa super parâmetro
    required this.highlightScenariosData,
    required this.onStartScenario,
    required this.isLoading,
  });

  @override
  State<HighlightSectionWidget> createState() => _HighlightSectionWidgetState();
}

/// O estado para [HighlightSectionWidget].
///
/// Gerencia o [PageController] para o [PageView], um [Timer] para a rotação
/// automática, e o índice da página atual [_currentPage]. Também lida com
/// a inicialização e descarte desses recursos.
class _HighlightSectionWidgetState extends State<HighlightSectionWidget> {
  /// Controlador para o [PageView] que exibe os destaques.
  late final PageController _pageController;

  /// Timer para controlar a rotação automática dos destaques.
  /// É nulo quando a rotação não está ativa.
  Timer? _highlightTimer;

  /// Índice da página (destaque) atualmente visível no [PageView].
  int _currentPage = 0;

  /// Duração entre as transições automáticas de página.
  final Duration _highlightRotationDuration = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Inicia o timer após o primeiro frame, se houver cenários e o widget estiver montado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.highlightScenariosData.isNotEmpty) {
        _startHighlightTimerIfNeeded();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HighlightSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinicia o timer se a lista de cenários mudar ou se o carregamento terminar.
    if (widget.highlightScenariosData.isNotEmpty &&
        (_highlightTimer == null || !_highlightTimer!.isActive)) {
      _startHighlightTimerIfNeeded();
    } else if (widget.highlightScenariosData.length <= 1 &&
        _highlightTimer != null) {
      _stopHighlightTimer();
    }
  }

  @override
  void dispose() {
    // Libera os recursos.
    _pageController.dispose();
    _highlightTimer?.cancel();
    super.dispose();
  }

  /// Inicia o [Timer] para a rotação automática, se necessário.
  void _startHighlightTimerIfNeeded() {
    if (widget.highlightScenariosData.length > 1 &&
        (_highlightTimer == null || !_highlightTimer!.isActive)) {
      _startHighlightTimer();
    }
  }

  /// Para o [Timer] de rotação.
  void _stopHighlightTimer() {
    _highlightTimer?.cancel();
    _highlightTimer = null;
  }

  /// Inicia ou reinicia o [Timer] para a rotação automática.
  void _startHighlightTimer() {
    _stopHighlightTimer();
    if (!mounted || widget.highlightScenariosData.length <= 1) return;

    _highlightTimer = Timer.periodic(_highlightRotationDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final highlightCount = widget.highlightScenariosData.length;
      if (highlightCount > 1 && _pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? _currentPage) + 1;
        if (nextPage >= highlightCount) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _stopHighlightTimer();
      }
    });
  }

  /// Callback para atualização do índice da página.
  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
      _startHighlightTimer(); // Reinicia timer na interação manual/automática
    }
  }

  /// Callback para clique nos pontos do indicador.
  void _onDotClicked(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Widget de carregamento.
    Widget loadingWidget = const Center(child: CircularProgressIndicator());

    /// Widget de estado vazio.
    Widget emptyWidget = const Center(child: Text('No highlights available.'));

    // Lógica para exibir loading ou empty state.
    if (widget.isLoading && widget.highlightScenariosData.isEmpty) {
      return loadingWidget;
    }
    if (widget.highlightScenariosData.isEmpty && !widget.isLoading) {
      return emptyWidget;
    }

    // Constrói a UI principal com PageView e indicador.
    return Stack(
      fit: StackFit.expand,
      children: [
        // --- Camada 1: PageView com os cards de destaque ---
        PageView.builder(
          controller: _pageController,
          itemCount: widget.highlightScenariosData.length,
          itemBuilder: (context, index) {
            final scenarioData = widget.highlightScenariosData[index];
            // Cria um card de destaque para cada cenário.
            return _HighlightCard(
              scenario: scenarioData.scenario, // Passa o Scenario
              decodedImageBytes:
                  scenarioData
                      .decodedImageBytes, // Passa os bytes decodificados
              onStart: () {
                _stopHighlightTimer(); // Para a rotação ao iniciar um cenário.
                widget.onStartScenario(
                  scenarioData.scenario,
                ); // Chama o callback passado.
              },
            );
          },
          onPageChanged: _onPageChanged,
        ),
        // --- Camada 2: Indicador de Página ---
        if (widget.highlightScenariosData.length > 1)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.highlightScenariosData.length,
                effect: WormEffect(
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.grey.shade600,
                ),
                onDotClicked: _onDotClicked,
              ),
            ),
          ),
      ],
    );
  }
}

/// Um widget stateless que constrói um card individual para a seção de destaque [PageView],
/// utilizando [ImageWithOverlayWidget] para o efeito de fundo.
///
/// Exibe a imagem de fundo do cenário (pré-decodificada), um overlay gradiente,
/// o título e um botão para iniciar o cenário.
class _HighlightCard extends StatelessWidget {
  /// O cenário a ser exibido neste card.
  final Scenario scenario;

  /// Callback chamado quando o botão "Start Scenario" é pressionado.
  final VoidCallback onStart;

  /// Os bytes da imagem de fundo do cenário, já decodificados (opcional).
  final Uint8List? decodedImageBytes;

  /// Cria uma instância de [_HighlightCard].
  const _HighlightCard({
    required this.scenario,
    required this.onStart,
    this.decodedImageBytes, // Alterado de imageBase64
  });

  // REMOVIDO: _decodeImage - A imagem já vem decodificada.

  @override
  Widget build(BuildContext context) {
    // A imagem já vem como decodedImageBytes.
    // final imageBytes = ImageUtils.decodeCleanBase64Image(imageBase64); // Removido

    // Calcula o padding superior necessário para o conteúdo.
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    // Define o widget de overlay (gradiente)
    final overlay = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withAlpha((255 * 0.7).round()), // Mais escuro na base
            Colors.black.withAlpha((255 * 0.4).round()),
            Colors.transparent, // Transparente no topo
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );

    // Define o conteúdo principal (título e botão) posicionado
    final cardContent = Positioned(
      bottom: 30,
      left: 16,
      right: 16,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Título do Cenário
            Text(
              scenario.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black.withAlpha((255 * 0.5).round()),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            /// Botão para Iniciar o Cenário
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Scenario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );

    // Usa ImageWithOverlayWidget para montar o card
    return ImageWithOverlayWidget(
      // Alterado de BlurredBackground
      imageBytes: decodedImageBytes, // Usa os bytes pré-decodificados
      // sigmaX e sigmaY removidos
      overlayWidget: overlay, // Passa o gradiente como overlay
      child: cardContent, // Passa o conteúdo posicionado como filho
      // Placeholder padrão do ImageWithOverlayWidget será usado se decodedImageBytes for nulo
    );
  }
}

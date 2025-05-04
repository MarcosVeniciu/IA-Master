import 'dart:async'; // Para Timer
import 'dart:convert'; // Para base64Decode
import 'dart:typed_data'; // Para Uint8List

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importa o indicador de página
import 'package:ai_master/models/scenario.dart';

/// Um widget stateful dedicado para gerenciar a seção de destaque rotativa.
///
/// Este widget isola o estado do [PageController], [Timer] e índice da página atual,
/// evitando que a atualização do indicador de página cause a reconstrução de toda
/// a view principal. Exibe uma lista de [Scenario]s em um [PageView] com
/// navegação automática e manual.
class HighlightSectionWidget extends StatefulWidget {
  /// A lista de cenários a serem exibidos como destaque (geralmente os 3 primeiros).
  final List<Scenario> highlightScenarios;

  /// Callback chamado quando o botão "Start Scenario" em um destaque é pressionado.
  /// Passa o [Scenario] selecionado como argumento.
  final Function(Scenario) onStartScenario;

  /// Indica se os cenários ainda estão sendo carregados pela view principal.
  /// Usado para exibir um indicador de progresso.
  final bool isLoading;

  /// Cria uma instância de [HighlightSectionWidget].
  ///
  /// Requer [highlightScenarios], [onStartScenario] e [isLoading].
  const HighlightSectionWidget({
    super.key, // Usa super parâmetro
    required this.highlightScenarios,
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
    // Usar addPostFrameCallback garante que o contexto e o widget estão prontos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.highlightScenarios.isNotEmpty) {
        _startHighlightTimerIfNeeded();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HighlightSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinicia o timer se a lista de cenários mudar (ex: após carregamento inicial)
    // ou se o estado de carregamento mudar de true para false com cenários disponíveis.
    // Garante que o timer inicie assim que os dados estiverem prontos.
    if (widget.highlightScenarios.isNotEmpty &&
        (_highlightTimer == null || !_highlightTimer!.isActive)) {
      _startHighlightTimerIfNeeded();
    } else if (widget.highlightScenarios.length <= 1 &&
        _highlightTimer != null) {
      // Para o timer se o número de cenários for reduzido para 1 ou 0.
      _stopHighlightTimer();
    }
  }

  @override
  void dispose() {
    // Libera os recursos do PageController e cancela o Timer para evitar memory leaks.
    _pageController.dispose();
    _highlightTimer?.cancel();
    super.dispose();
  }

  /// Inicia o [Timer] para a rotação automática, se houver mais de um cenário
  /// e o timer não estiver já ativo.
  void _startHighlightTimerIfNeeded() {
    // Só inicia se houver mais de um cenário e o timer não estiver ativo.
    if (widget.highlightScenarios.length > 1 &&
        (_highlightTimer == null || !_highlightTimer!.isActive)) {
      _startHighlightTimer();
    }
  }

  /// Para o [Timer] de rotação e define [_highlightTimer] como nulo.
  void _stopHighlightTimer() {
    _highlightTimer?.cancel();
    _highlightTimer = null;
  }

  /// Inicia ou reinicia o [Timer] para a rotação automática dos destaques.
  /// Cancela qualquer timer existente antes de criar um novo.
  void _startHighlightTimer() {
    _stopHighlightTimer(); // Garante que apenas um timer execute por vez.
    // Não inicia se o widget não estiver montado ou se não houver necessidade de rotação.
    if (!mounted || widget.highlightScenarios.length <= 1) return;

    _highlightTimer = Timer.periodic(_highlightRotationDuration, (timer) {
      // Verifica se o widget ainda está montado dentro do callback do timer.
      if (!mounted) {
        timer.cancel();
        return;
      }

      final highlightCount = widget.highlightScenarios.length;

      // Verifica se há mais de um destaque e se o PageController está pronto.
      if (highlightCount > 1 && _pageController.hasClients) {
        // Calcula a próxima página, voltando ao início se necessário.
        int nextPage = (_pageController.page?.round() ?? _currentPage) + 1;
        if (nextPage >= highlightCount) {
          nextPage = 0; // Loop de volta para o primeiro item.
        }
        // Anima a transição para a próxima página.
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        // A atualização do _currentPage ocorrerá no callback _onPageChanged.
      } else {
        // Se por algum motivo só resta um item ou o controller não está pronto, para o timer.
        _stopHighlightTimer();
      }
    });
  }

  /// Callback chamado pelo [PageView] quando a página visível muda.
  /// Atualiza o estado local [_currentPage] para refletir a mudança e
  /// reinicia o timer de rotação automática.
  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index; // Atualiza o índice da página atual no estado.
      });
      // Reinicia o timer sempre que o usuário ou a automação muda a página.
      _startHighlightTimer();
    }
  }

  /// Callback chamado quando um ponto do [SmoothPageIndicator] é clicado.
  /// Anima o [PageView] para a página correspondente ao ponto clicado.
  void _onDotClicked(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      // O _onPageChanged será chamado automaticamente após a animação,
      // atualizando _currentPage e reiniciando o timer.
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Widget a ser exibido durante o carregamento inicial dos cenários.
    Widget loadingWidget = const Center(child: CircularProgressIndicator());

    /// Widget a ser exibido quando não há cenários de destaque disponíveis.
    Widget emptyWidget = const Center(child: Text('No highlights available.'));

    // Exibe o widget de carregamento se estiver carregando e a lista estiver vazia.
    if (widget.isLoading && widget.highlightScenarios.isEmpty) {
      return loadingWidget;
    }

    // Exibe o widget de estado vazio se não estiver carregando e a lista estiver vazia.
    if (widget.highlightScenarios.isEmpty && !widget.isLoading) {
      return emptyWidget;
    }

    // Usa um Stack para sobrepor o indicador de página ao PageView.
    return Stack(
      fit: StackFit.expand, // Faz o Stack ocupar todo o espaço disponível.
      children: [
        // --- Camada 1: PageView com os cards de destaque ---
        PageView.builder(
          controller: _pageController,
          itemCount: widget.highlightScenarios.length,
          itemBuilder: (context, index) {
            final scenario = widget.highlightScenarios[index];
            // Cria um card de destaque para cada cenário.
            return _HighlightCard(
              scenario: scenario,
              imageBase64: scenario.imageBase64,
              onStart: () {
                _stopHighlightTimer(); // Para a rotação ao iniciar um cenário.
                widget.onStartScenario(scenario); // Chama o callback passado.
              },
            );
          },
          onPageChanged:
              _onPageChanged, // Registra o callback de mudança de página.
        ),
        // --- Camada 2: Indicador de Página (sobre o PageView) ---
        // Só exibe o indicador se houver mais de uma página.
        if (widget.highlightScenarios.length > 1)
          Align(
            alignment:
                Alignment.bottomCenter, // Posiciona na parte inferior central.
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ), // Espaçamento inferior.
              child: SmoothPageIndicator(
                controller: _pageController, // Vincula ao PageController.
                count: widget.highlightScenarios.length, // Número de pontos.
                effect: WormEffect(
                  // Efeito visual do indicador.
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                  activeDotColor:
                      Theme.of(
                        context,
                      ).colorScheme.primary, // Cor do ponto ativo.
                  dotColor: Colors.grey.shade600, // Cor dos pontos inativos.
                ),
                onDotClicked:
                    _onDotClicked, // Registra o callback de clique no ponto.
              ),
            ),
          ),
      ],
    );
  }
}

/// Um widget stateless que constrói um card individual para a seção de destaque [PageView].
///
/// Exibe a imagem de fundo do cenário, um overlay gradiente, o título
/// e um botão para iniciar o cenário.
class _HighlightCard extends StatelessWidget {
  /// O cenário a ser exibido neste card.
  final Scenario scenario;

  /// Callback chamado quando o botão "Start Scenario" é pressionado.
  final VoidCallback onStart;

  /// A imagem de fundo do cenário em formato Base64 (opcional).
  final String? imageBase64;

  // final ShapeBorder? shape; // Removido - não utilizado

  /// Cria uma instância de [_HighlightCard].
  const _HighlightCard({
    required this.scenario,
    required this.onStart,
    this.imageBase64,
    // this.shape, // Removido - não utilizado
  });

  /// Tenta decodificar a string Base64 da imagem.
  ///
  /// Lida com strings que podem ou não conter o prefixo `data:image/...;base64,`
  /// e adiciona o padding `=` necessário para o decodificador Base64.
  /// Retorna `null` se a string for nula, vazia ou a decodificação falhar.
  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      // Remove o prefixo comum de Data URLs, se presente.
      final String encoded =
          base64String.contains(',')
              ? base64String.split(',').last
              : base64String;
      // Adiciona padding '=' se necessário para que o comprimento seja múltiplo de 4.
      final String padded = encoded.padRight(
        (encoded.length + 3) ~/ 4 * 4,
        '=',
      );
      return base64Decode(padded);
    } catch (e) {
      // Registra um erro se a decodificação falhar.
      // print("Erro ao decodificar imagem Base64 no HighlightCard: $e"); // Removido - usar logger
      return null; // Retorna null em caso de erro.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tenta decodificar a imagem.
    final imageBytes = _decodeImage(imageBase64);

    // Calcula o padding superior necessário para evitar sobreposição pela AppBar fixa
    // e pela status bar do sistema. kToolbarHeight é a altura padrão da AppBar.
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    /// Constrói a interface do card de destaque.
    ///
    /// O widget [Card] foi removido intencionalmente para permitir que a imagem
    /// de fundo ([Image.memory]) se estenda completamente sob a [AppBar] transparente
    /// e a status bar do sistema, criando o efeito de "hero image" desejado.
    /// O [Stack] é agora o widget raiz, gerenciando as camadas de imagem,
    /// overlay e conteúdo. O padding superior ([topPadding]) é aplicado
    /// apenas ao conteúdo textual e botão para evitar que eles fiquem sob a AppBar.
    // O Card foi removido para permitir que a imagem se estenda sob a status bar.
    // O Stack agora é o widget raiz retornado.
    return Stack(
      // Padding removido daqui // Mantém o comentário original, embora o padding estivesse no Card
      fit:
          StackFit.expand, // Faz o Stack interno preencher o espaço disponível.
      children: [
        // --- Camada 1: Imagem de Fundo ---
        if (imageBytes != null)
          Image.memory(
            imageBytes,
            fit:
                BoxFit
                    .cover, // Cobre todo o espaço do card, cortando se necessário.
            // Adiciona um fade-in suave para a imagem quando ela carrega.
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child; // Se carregou rápido, mostra direto.
              }
              return AnimatedOpacity(
                opacity:
                    frame == null ? 0 : 1, // Anima a opacidade de 0 para 1.
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: child,
              );
            },
            // Exibe um ícone de imagem quebrada se houver erro ao carregar.
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade800, // Fundo cinza escuro.
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          )
        else
          // Fallback se não houver imagem: um container cinza com um ícone.
          Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),

        // --- Camada 2: Overlay Escuro Semi-transparente ---
        // Adiciona um gradiente escuro na parte inferior para melhorar a
        // legibilidade do texto sobre a imagem.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withAlpha(
                  (255 * 0.7).round(),
                ), // Mais escuro na base
                Colors.black.withAlpha((255 * 0.4).round()),
                Colors.transparent, // Transparente no topo
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [
                0.0,
                0.5,
                1.0,
              ], // Controla a transição do gradiente.
            ),
          ),
        ),

        // --- Camada 3: Conteúdo (Texto e Botão) ---
        // Posiciona o conteúdo na parte inferior do card, com padding superior.
        Positioned(
          bottom: 30, // Aumenta um pouco o espaço da borda inferior
          left: 16,
          right: 16,
          child: Padding(
            // Adiciona Padding apenas ao redor do conteúdo textual/botão
            padding: EdgeInsets.only(top: topPadding),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinha texto à esquerda.
              mainAxisSize:
                  MainAxisSize.min, // Encolhe a coluna ao tamanho do conteúdo.
              children: [
                /// Título do Cenário
                Text(
                  scenario.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white, // Texto branco para contraste.
                    fontWeight: FontWeight.bold,
                    // Sombra para melhorar legibilidade sobre imagens variadas.
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withAlpha((255 * 0.5).round()),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  maxLines: 2, // Limita o título a duas linhas.
                  overflow:
                      TextOverflow
                          .ellipsis, // Adiciona '...' se o texto exceder.
                ),
                const SizedBox(height: 12), // Espaçamento entre título e botão.
                /// Botão para Iniciar o Cenário
                ElevatedButton.icon(
                  onPressed: onStart, // Chama o callback fornecido.
                  icon: const Icon(Icons.play_arrow), // Ícone de play.
                  label: const Text('Start Scenario'), // Texto do botão.
                  style: ElevatedButton.styleFrom(
                    // Estilo visual do botão.
                    backgroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.primary, // Cor primária do tema.
                    foregroundColor:
                        Theme.of(context)
                            .colorScheme
                            .onPrimary, // Cor do texto sobre a cor primária.
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, // Padding horizontal.
                      vertical: 12, // Padding vertical.
                    ),
                    textStyle:
                        Theme.of(
                          context,
                        ).textTheme.labelLarge, // Estilo do texto.
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ); // Fim do Stack
  }
}

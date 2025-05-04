import 'dart:convert'; // Para base64Decode
import 'package:flutter/material.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:timeago/timeago.dart'
    as timeago; // Para formatação de data relativa

/// {@template ongoing_adventure_card}
/// Um widget que exibe um card visualmente rico para uma aventura em andamento.
///
/// Mostra uma imagem de fundo (do cenário), o título da aventura, uma barra
/// de progresso com percentual, a data do último acesso formatada de forma
/// relativa (ex: "há 3 dias") e um botão de play para continuar.
/// {@endtemplate}
class OngoingAdventureCard extends StatelessWidget {
  /// A aventura cujos dados serão exibidos.
  final Adventure adventure;

  /// A imagem de fundo do cenário em formato Base64. Pode ser nula.
  final String? scenarioImageBase64;

  /// Callback chamado quando o botão de play ou o card é tocado.
  /// Geralmente usado para navegar para a tela da aventura.
  final VoidCallback onTap;

  /// {@macro ongoing_adventure_card}
  const OngoingAdventureCard({
    super.key, // Usa super parâmetro
    required this.adventure,
    required this.onTap,
    this.scenarioImageBase64, // Tornou-se opcional
  });

  @override
  Widget build(BuildContext context) {
    // Define a largura do card com base na largura da tela.
    final width = MediaQuery.of(context).size.width * 0.42;
    // Define o valor do progresso (0.0 a 1.0), tratando nulo como 0.0.
    final progressValue =
        adventure.progressIndicator?.clamp(0.0, 1.0) ?? 0.0; // Renomeado

    // Configura o locale do timeago para Português do Brasil, se ainda não estiver.
    // É seguro chamar múltiplas vezes, mas idealmente seria configurado uma vez na inicialização do app.
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

    // Formata a data da última jogada de forma relativa.
    final lastPlayedDateTime = DateTime.fromMillisecondsSinceEpoch(
      adventure.lastPlayedDate, // Renomeado
    );
    final formattedDate = timeago.format(lastPlayedDateTime, locale: 'pt_BR');

    return SizedBox(
      width: width,
      child: Card(
        elevation: 3, // Aumenta a elevação para destaque
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordas mais arredondadas
        ),
        clipBehavior:
            Clip.antiAlias, // Garante que o conteúdo interno respeite as bordas
        margin: const EdgeInsets.only(right: 16), // Mantém a margem direita
        child: InkWell(
          // Permite que todo o card seja clicável
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 9, // Proporção comum para thumbnails
            child: Stack(
              fit: StackFit.expand, // Faz os filhos preencherem o Stack
              children: [
                // --- Camada 1: Imagem de Fundo ou Placeholder ---
                _buildBackgroundImage(context),

                // --- Camada 2: Overlay Escuro para Contraste ---
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha((255 * 0.1).round()),
                        Colors.black.withAlpha(
                          (255 * 0.7).round(),
                        ), // Mais escuro na base
                      ],
                    ),
                  ),
                ),

                // --- Camada 3: Conteúdo Textual e Barra de Progresso ---
                Padding(
                  padding: const EdgeInsets.all(10.0), // Padding ajustado
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da Aventura
                      Text(
                        adventure.scenarioTitle, // Renomeado
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15, // Tamanho ajustado
                          fontWeight: FontWeight.bold, // Negrito
                          color: Colors.white,
                          shadows: [
                            // Sombra para legibilidade
                            Shadow(blurRadius: 2.0, color: Colors.black54),
                          ],
                        ),
                      ),

                      const Spacer(), // Empurra o conteúdo abaixo para o fundo
                      // Barra de Progresso
                      _buildProgressBar(context, progressValue),

                      const SizedBox(height: 5), // Espaçamento ajustado
                      // Data do Último Acesso (Relativa)
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 11, // Tamanho ajustado
                          color: Colors.white70, // Cor suave
                          shadows: [
                            // Sombra para legibilidade
                            Shadow(blurRadius: 1.0, color: Colors.black45),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Camada 4: Botão de Play ---
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 18, // Tamanho ajustado
                    backgroundColor: Colors.white.withAlpha(
                      (255 * 0.85).round(),
                    ), // Fundo semi-transparente
                    child: IconButton(
                      iconSize: 20, // Tamanho do ícone ajustado
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.black87,
                      onPressed: onTap, // Reutiliza o onTap principal
                      tooltip: 'Continuar Aventura',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a imagem de fundo ou um placeholder.
  Widget _buildBackgroundImage(BuildContext context) {
    if (scenarioImageBase64 != null && scenarioImageBase64!.isNotEmpty) {
      try {
        // Tenta decodificar e exibir a imagem
        final imageBytes = base64Decode(scenarioImageBase64!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover, // Garante que a imagem cubra o card
          // Adiciona um frameBuilder para um fade-in suave
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            );
          },
          // Exibe um erro se a decodificação falhar
          errorBuilder:
              (context, error, stackTrace) =>
                  _buildPlaceholder(context, Icons.broken_image),
        );
      } catch (e) {
        // Se a decodificação falhar (base64 inválido)
        // print("Erro ao decodificar imagem base64: $e"); // Removido - usar logger
        return _buildPlaceholder(context, Icons.broken_image);
      }
    } else {
      // Se não houver imagem base64
      return _buildPlaceholder(context, Icons.image_not_supported);
    }
  }

  /// Constrói um widget placeholder centralizado.
  Widget _buildPlaceholder(BuildContext context, IconData icon) {
    return Container(
      color: Colors.grey[800], // Fundo escuro para o placeholder
      child: Center(child: Icon(icon, color: Colors.grey[600], size: 40)),
    );
  }

  /// Constrói a barra de progresso visual com texto percentual.
  Widget _buildProgressBar(BuildContext context, double progressValue) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Fundo (track) da barra
        Container(
          height: 18, // Altura ajustada
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(
              (255 * 0.3).round(),
            ), // Track semi-transparente
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        // Parte preenchida da barra
        FractionallySizedBox(
          widthFactor: progressValue,
          child: Container(
            height: 18, // Mesma altura do track
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(
                (255 * 0.85).round(),
              ), // Cor primária com opacidade
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        // Texto do progresso
        Text(
          '${(progressValue * 100).toInt()}% concluído',
          style: const TextStyle(
            fontSize: 10, // Tamanho ajustado
            fontWeight: FontWeight.w600, // Peso ajustado
            color: Colors.white,
            shadows: [
              // Sombra para legibilidade
              Shadow(blurRadius: 1.0, color: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }
}

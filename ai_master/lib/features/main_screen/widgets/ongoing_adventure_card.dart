import 'dart:typed_data'; // Para Uint8List
import 'dart:ui'; // Para ImageFilter
import 'package:flutter/foundation.dart'; // Para debugPrint (opcional, pode ser removido depois)
import 'package:flutter/material.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/utils/image_utils.dart'; // Importa o utilitário
import 'package:ai_master/widgets/blurred_background.dart'; // Importa o widget reutilizável
import 'package:timeago/timeago.dart'
    as timeago; // Para formatação de data relativa

/// {@template ongoing_adventure_card}
/// Um widget que exibe um card visualmente rico para uma aventura em andamento,
/// utilizando [ImageWithOverlayWidget] para exibir uma imagem de fundo com um overlay.
///
/// Mostra uma imagem de fundo (do cenário), um overlay gradiente,
/// o título da aventura, uma barra de progresso com percentual,
/// a data do último acesso formatada de forma relativa (ex: "há 3 dias")
/// e um botão de play para continuar.
/// {@endtemplate}
class OngoingAdventureCard extends StatelessWidget {
  /// A aventura cujos dados serão exibidos.
  final Adventure adventure;

  /// Os bytes da imagem de fundo do cenário, já decodificados. Pode ser nulo.
  final Uint8List? decodedImageBytes;

  /// Callback chamado quando o botão de play ou o card é tocado.
  /// Geralmente usado para navegar para a tela da aventura.
  final VoidCallback onTap;

  /// {@macro ongoing_adventure_card}
  const OngoingAdventureCard({
    super.key, // Usa super parâmetro
    required this.adventure,
    required this.onTap,
    this.decodedImageBytes, // Alterado de scenarioImageBase64
  });

  @override
  Widget build(BuildContext context) {
    // Define a largura do card com base na largura da tela.
    final width = MediaQuery.of(context).size.width * 0.70;
    // Define o valor do progresso (0.0 a 1.0), tratando nulo como 0.0.
    final progressValue = adventure.progressIndicator?.clamp(0.0, 1.0) ?? 0.0;

    // Configura o locale do timeago para Português do Brasil, se ainda não estiver.
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

    // Formata a data da última jogada de forma relativa.
    final lastPlayedDateTime = DateTime.fromMillisecondsSinceEpoch(
      adventure.lastPlayedDate,
    );
    final formattedDate = timeago.format(lastPlayedDateTime, locale: 'pt_BR');

    // A imagem agora é recebida como Uint8List? (decodedImageBytes),
    // então não há necessidade de decodificar aqui.
    // Opcionalmente, pode-se manter um log se a imagem é nula ou não, se útil para debug.
    if (kDebugMode) {
      // Este log é opcional e pode ser removido se não for necessário.
      // Mantido para consistência com o comportamento anterior de log, mas agora mais simples.
      debugPrint(
        'OngoingAdventureCard (${adventure.adventureTitle}): decodedImageBytes is ${decodedImageBytes == null ? 'null' : 'present (length: ${decodedImageBytes!.lengthInBytes})'}',
      );
    }

    // Define o widget de overlay (gradiente)
    final overlay = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha((255 * 0.1).round()),
            Colors.black.withAlpha((255 * 0.7).round()), // Mais escuro na base
          ],
        ),
      ),
    );

    // Define o conteúdo principal (textos, barra, botão)
    final cardContent = Stack(
      children: [
        // --- Conteúdo Textual e Barra de Progresso ---
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título Principal (Adventure Title)
              Text(
                adventure.adventureTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 4),
              // Subtítulo (Scenario Title)
              Text(
                adventure.scenarioTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  shadows: const [
                    Shadow(blurRadius: 1.0, color: Colors.black45),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Barra de Progresso (Centralizada no Card)
              Align(
                alignment: Alignment.center,
                child: _buildProgressBar(context, progressValue),
              ),
              const SizedBox(height: 5),
              // Data do Último Acesso (Relativa)
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  shadows: [Shadow(blurRadius: 1.0, color: Colors.black45)],
                ),
              ),
            ],
          ),
        ),
        // --- Botão de Play ---
        Positioned(
          bottom: 8,
          right: 8,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withAlpha((255 * 0.85).round()),
            child: IconButton(
              iconSize: 20,
              icon: const Icon(Icons.play_arrow),
              color: Colors.black87,
              onPressed: onTap,
              tooltip: 'Continuar Aventura',
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(right: 16),
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ImageWithOverlayWidget(
              // Alterado de BlurredBackground
              imageBytes:
                  decodedImageBytes, // Usa os bytes decodificados diretamente
              // sigmaX e sigmaY removidos
              placeholder: _buildPlaceholder(
                context,
                Icons.image_not_supported,
              ),
              overlayWidget: overlay, // Passa o gradiente como overlay
              child: cardContent, // Passa o conteúdo como filho
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói um widget placeholder centralizado.
  /// Usado pelo [ImageWithOverlayWidget] se a imagem não puder ser carregada.
  Widget _buildPlaceholder(BuildContext context, IconData icon) {
    return Container(
      color: Colors.grey[800], // Fundo escuro para o placeholder
      child: Center(child: Icon(icon, color: Colors.grey[600], size: 40)),
    );
  }

  /// {@template build_progress_bar}
  /// Constrói a barra de progresso visual.
  /// (Implementação original mantida)
  /// {@endtemplate}
  Widget _buildProgressBar(BuildContext context, double progressValue) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Fundo (track) da barra
        Container(
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.3).round()),
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        // Parte preenchida da barra
        FractionallySizedBox(
          widthFactor: progressValue,
          child: Container(
            height: 18,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha((255 * 0.85).round()),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
        // Texto do progresso
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '${(progressValue * 100).toInt()}% concluído',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 1.0, color: Colors.black87)],
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:typed_data'; // Para Uint8List

import 'package:flutter/material.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/utils/image_utils.dart'; // Importa o utilitário de imagem
import 'package:ai_master/widgets/blurred_background.dart'; // Importa o widget reutilizável

/// Um widget que exibe um card de cenário com um design visualmente atraente,
/// utilizando [ImageWithOverlayWidget] para exibir uma imagem de fundo com um overlay.
///
/// Apresenta uma imagem de fundo (pré-decodificada), sobreposta por um
/// overlay escuro para contraste, e informações textuais
/// como título, subtítulo (ambientação) e descrição breve (também da ambientação).
/// Inclui um botão "Start" para iniciar a interação com o cenário.
///
/// Este card é projetado para ser usado em layouts como [GridView], adaptando-se
/// a diferentes tamanhos de tela através de um [LayoutBuilder] (exemplo de uso comentado no final).
class AvailableScenarioCard extends StatelessWidget {
  /// O objeto [Scenario] contendo os dados a serem exibidos no card.
  ///
  /// Este objeto deve fornecer pelo menos:
  /// - `imageBase64` (String?): A imagem de fundo em formato base64 (opcional).
  ///   Se nula ou inválida, um placeholder será exibido.
  /// - `title` (String): O título principal do cenário, exibido com destaque.
  /// - `ambiance` (String): Uma string usada tanto como subtítulo (primeira linha)
  ///   quanto como descrição breve (até 4 linhas) do cenário.
  final Scenario scenario;

  /// A função [VoidCallback] que será executada quando o usuário tocar
  /// no botão "Start".
  ///
  /// Esta função deve conter a lógica necessária para iniciar a aventura
  /// correspondente ao [scenario] ou navegar para a tela apropriada.
  final VoidCallback onStart;

  /// Os bytes da imagem de fundo do cenário, já decodificados. Pode ser nulo.
  final Uint8List? decodedImageBytes;

  /// Cria um widget [AvailableScenarioCard].
  ///
  /// Parâmetros:
  ///   - `key`: Chave opcional para o widget, usada pelo framework Flutter.
  ///   - `scenario`: O [Scenario] cujos dados serão exibidos (obrigatório).
  ///   - `onStart`: O [VoidCallback] a ser chamado ao pressionar o botão "Start" (obrigatório).
  ///   - `decodedImageBytes`: Os bytes da imagem pré-decodificada (opcional).
  const AvailableScenarioCard({
    super.key,
    required this.scenario,
    required this.onStart,
    this.decodedImageBytes,
  });

  /// Constrói a interface do usuário usando o widget reutilizável [ImageWithOverlayWidget].
  ///
  /// Define a proporção e o arredondamento, e então
  /// utiliza [ImageWithOverlayWidget] para renderizar o fundo com a imagem pré-decodificada
  /// e overlay de cor sólida, passando o conteúdo textual e o botão como filho.
  @override
  Widget build(BuildContext context) {
    // A imagem agora é recebida como decodedImageBytes, não precisa decodificar aqui.

    /// Define a proporção do card.
    return AspectRatio(
      aspectRatio: 3 / 4,

      /// Aplica bordas arredondadas.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        /// Usa o widget reutilizável para o fundo com imagem e overlay.
        child: ImageWithOverlayWidget(
          // Alterado de BlurredBackground
          imageBytes: decodedImageBytes, // Usa os bytes pré-decodificados
          // sigmaX e sigmaY removidos
          /// Define o overlay como um container semitransparente preto.
          overlayWidget: Container(color: Colors.black.withOpacity(0.45)),

          /// Define o placeholder a ser usado se decodedImageBytes for nulo.
          placeholder: _buildImagePlaceholder(),

          /// O conteúdo principal do card (textos e botão) é passado como filho.
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Título do Cenário.
                Text(
                  scenario.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                /// Subtítulo/Ambientação.
                Text(
                  scenario.ambiance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Colors.black38,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                /// Descrição Breve (usando ambiance).
                Expanded(
                  child: Text(
                    scenario.ambiance,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                /// Botão "Start".
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  /// Método auxiliar privado para construir um widget [Container] cinza
  /// com um ícone centralizado. Usado como placeholder pelo [ImageWithOverlayWidget].
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}

/*
// Exemplo de uso em um GridView Responsivo:
// (O mesmo exemplo de antes, mostrando como usar AvailableScenarioCard)
// LayoutBuilder(
//   builder: (context, constraints) {
//     int crossAxisCount = 2;
//     if (constraints.maxWidth > 900) {
//       crossAxisCount = 4;
//     } else if (constraints.maxWidth > 600) {
//       crossAxisCount = 3;
//     }
//     const double childAspectRatio = 3 / 4;
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         childAspectRatio: childAspectRatio,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       itemCount: scenarios.length,
//       itemBuilder: (context, index) {
//         final sc = scenarios[index];
//         return AvailableScenarioCard(
//           scenario: sc,
//           onStart: () { /* ... */ },
//         );
//       },
//     );
//   },
// )
*/

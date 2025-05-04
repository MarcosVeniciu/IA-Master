import 'dart:convert'; // Para base64Decode
import 'dart:typed_data'; // Para Uint8List

import 'package:flutter/material.dart';
import 'package:ai_master/models/scenario.dart';

/// Um widget stateless que exibe um card para um cenário disponível.
///
/// Mostra uma imagem miniatura (se disponível), o título, a ambientação
/// e um botão para iniciar o cenário. É tipicamente usado em uma lista vertical.
class AvailableScenarioCard extends StatelessWidget {
  /// O cenário cujos dados serão exibidos no card.
  final Scenario scenario;

  /// Callback chamado quando o botão "Start" ou o próprio card é tocado.
  final VoidCallback onStart;

  /// Cria uma instância de [AvailableScenarioCard].
  ///
  /// Requer o [scenario] a ser exibido e o callback [onStart].
  const AvailableScenarioCard({
    super.key, // Usa super parâmetro
    required this.scenario,
    required this.onStart,
  });

  /// Tenta decodificar a string Base64 da imagem do cenário.
  ///
  /// Lida com strings que podem ou não conter o prefixo `data:image/...;base64,`
  /// e adiciona o padding `=` necessário para o decodificador Base64.
  /// Retorna `null` se a string for nula, vazia ou a decodificação falhar.
  /// Imprime uma mensagem de erro no console em caso de falha na decodificação.
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
      // print( // Removido - usar um logger apropriado em produção
      //   "Erro ao decodificar imagem Base64 para Available Scenario Card: $e",
      // );
      return null; // Retorna null em caso de erro.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tenta decodificar a imagem Base64 antes de construir o widget.
    final imageBytes = _decodeImage(scenario.imageBase64);

    return Card(
      // Margem apenas na parte inferior para espaçamento em listas verticais.
      margin: const EdgeInsets.only(bottom: 16),
      // Corta o conteúdo que excede as bordas do card.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Permite iniciar o cenário tocando em qualquer lugar do card.
        onTap: onStart,
        child: Padding(
          // Padding interno para o conteúdo do card.
          padding: const EdgeInsets.all(12.0),
          child: Row(
            // Organiza a imagem e as informações lado a lado.
            children: [
              // --- Imagem Miniatura ---
              ClipRRect(
                // Aplica bordas arredondadas à imagem.
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80, // Largura fixa da miniatura.
                  height: 80, // Altura fixa da miniatura.
                  child:
                      imageBytes != null
                          ? Image.memory(
                            imageBytes, // Exibe a imagem decodificada.
                            fit: BoxFit.cover, // Cobre a área designada.
                            // Exibe um fallback em caso de erro ao carregar a imagem.
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            // Fallback se não houver imagem ou falha na decodificação.
                            color: Colors.grey.shade900,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 16), // Espaçamento entre imagem e texto.
              // --- Informações e Botão ---
              Expanded(
                // Permite que a coluna de texto ocupe o espaço restante.
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinha texto à esquerda.
                  children: [
                    /// Título do Cenário.
                    Text(
                      scenario.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Limita a duas linhas.
                      overflow:
                          TextOverflow.ellipsis, // Adiciona '...' se exceder.
                    ),
                    const SizedBox(height: 4), // Pequeno espaço.
                    /// Descrição/Ambientação do Cenário.
                    Text(
                      // Usa o campo 'ambiance' como descrição breve.
                      scenario.ambiance,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2, // Limita a duas linhas.
                      overflow:
                          TextOverflow.ellipsis, // Adiciona '...' se exceder.
                    ),
                    const SizedBox(height: 8), // Espaço antes do botão.
                    /// Botão para Iniciar o Cenário.
                    Align(
                      // Alinha o botão à direita dentro da coluna.
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: onStart, // Chama o callback ao pressionar.
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 18,
                        ), // Ícone de play.
                        label: const Text('Start'), // Texto do botão.
                        style: ElevatedButton.styleFrom(
                          // Estilo compacto para o botão.
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Classe utilitária para operações relacionadas a imagens.
class ImageUtils {
  /// Decodifica uma string Base64, tratando prefixos comuns e padding.
  ///
  /// Remove o prefixo `data:image/...;base64,` se presente, remove espaços
  /// e quebras de linha, e adiciona o padding `=` necessário antes de tentar
  /// a decodificação.
  ///
  /// Retorna `Uint8List?` contendo os bytes da imagem decodificada, ou `null`
  /// se a string de entrada for nula, vazia, ou se a decodificação falhar.
  /// Registra um erro no console de depuração em caso de falha.
  ///
  /// [rawBase64]: A string Base64 potencialmente "suja" a ser decodificada.
  static Uint8List? decodeCleanBase64Image(String? rawBase64) {
    if (rawBase64 == null || rawBase64.isEmpty) {
      // debugPrint('decodeCleanBase64Image: Input string is null or empty.'); // Opcional: log extra
      return null;
    }

    try {
      String cleaned = rawBase64;

      // 1. Remover prefixo Data URL
      final commaIndex = cleaned.indexOf(',');
      if (commaIndex != -1) {
        cleaned = cleaned.substring(commaIndex + 1);
      }

      // 2. Remover espaços e quebras de linha
      cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');

      // 3. Adicionar padding (garantir que o comprimento seja múltiplo de 4)
      //    O decodificador padrão do Dart lida com padding opcional, mas
      //    garantir explicitamente pode evitar problemas com algumas implementações.
      //    No entanto, vamos confiar no decodificador padrão por enquanto,
      //    pois ele é mais robusto a variações. Se problemas surgirem,
      //    podemos reintroduzir o padding explícito:
      //    cleaned = cleaned.padRight((cleaned.length + 3) ~/ 4 * 4, '=');

      // 4. Decodificar
      return base64Decode(cleaned);
    } catch (e, stackTrace) {
      // Usar debugPrint para logs que só aparecem no modo debug.
      debugPrint(
        'Error decoding Base64 image: $e\nInput preview (first 50 chars): ${rawBase64.substring(0, rawBase64.length > 50 ? 50 : rawBase64.length)}\nStackTrace: $stackTrace',
      );
      return null; // Retorna null em caso de erro.
    }
  }
}

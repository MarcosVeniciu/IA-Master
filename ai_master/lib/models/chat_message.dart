import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// {@template chat_message}
/// Representa uma única mensagem dentro do chat de uma aventura.
/// {@endtemplate}
@freezed
class ChatMessage with _$ChatMessage {
  /// {@macro chat_message}
  const factory ChatMessage({
    /// Identificador único da mensagem (UUID).
    required String id,

    /// Identificador da aventura à qual esta mensagem pertence (Chave Estrangeira).
    required String adventureId,

    /// O remetente da mensagem.
    ///
    /// Valores comuns: 'player', 'ai', 'system'.
    required String sender,

    /// O conteúdo textual da mensagem.
    required String content,

    /// Timestamp da criação da mensagem.
    /// Armazenado como milissegundos desde a época (Unix epoch).
    required int timestamp,

    /// Status de sincronização da mensagem com um backend (se aplicável).
    ///
    /// Valores possíveis:
    /// - 0: Apenas local, não sincronizado.
    /// - 1: Sincronizando.
    /// - 2: Sincronizado com sucesso.
    /// - -1: Erro durante a sincronização.
    @Default(0) int syncStatus,
  }) = _ChatMessage;

  /// Construtor privado para uso do Freezed.
  const ChatMessage._();

  /// Cria uma instância de [ChatMessage] a partir de um mapa JSON.
  ///
  /// Utiliza o código gerado por `json_serializable`.
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Cria uma instância de [ChatMessage] a partir de um mapa do banco de dados SQFlite.
  ///
  /// Este método adapta o mapa vindo do SQFlite para o formato esperado
  /// pelo factory `fromJson`.
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    // O SQFlite retorna o mapa diretamente no formato que json_serializable espera.
    return ChatMessage.fromJson(map);
  }

  /// Converte a instância de [ChatMessage] em um mapa para persistência no SQFlite.
  ///
  /// Utiliza o código gerado por `json_serializable`.
  Map<String, dynamic> toMap() {
    return toJson();
  }
}

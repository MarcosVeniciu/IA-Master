import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_message.dart'; // Importa o modelo ChatMessage

part 'adventure.freezed.dart';
part 'adventure.g.dart';

/// {@template adventure}
/// Representa uma sessão de jogo (aventura) no sistema AI Master.
///
/// Contém metadados sobre a aventura, o estado atual do jogo e, opcionalmente,
/// o histórico de mensagens associado (carregado sob demanda).
/// {@endtemplate}
@freezed
class Adventure with _$Adventure {
  /// {@macro adventure}
  const factory Adventure({
    /// Identificador único da aventura (UUID).
    required String id,

    /// Título do cenário base da aventura.
    required String scenarioTitle, // @JsonKey removida do parâmetro
    /// o progresso atual na aventura, um valor numerico entre 0.0 e 1.0 representando a porcentagem de progresso ( quantidade de cenas concluidas em relaçao ao total de cenas da aventura)
    double? progressIndicator, // @JsonKey removida do parâmetro
    /// Estado completo do jogo serializado como uma string JSON.
    /// Inclui variáveis, status de personagens, inventário, etc.
    required String gameState, // @JsonKey removida do parâmetro
    /// Timestamp da última vez que a aventura foi jogada ou modificada.
    /// Armazenado como milissegundos desde a época (Unix epoch).
    required int lastPlayedDate, // @JsonKey removida do parâmetro
    /// Status de sincronização da aventura com um backend (se aplicável).
    ///
    /// Valores possíveis:
    /// - 0: Apenas local, não sincronizado.
    /// - 1: Sincronizando.
    /// - 2: Sincronizado com sucesso.
    /// - -1: Erro durante a sincronização.
    @Default(0) int syncStatus, // @JsonKey removida do parâmetro
    /// Lista de mensagens do chat associadas a esta aventura.
    /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
    /// É carregado sob demanda pelo [AdventureRepository].
    // @JsonKey removida do parâmetro, já que está no getter gerado.
    @Default([])
    List<ChatMessage> messages, // Tipo corrigido para List<ChatMessage>
  }) = _Adventure;

  /// Construtor privado para uso do Freezed.
  const Adventure._();

  /// Cria uma instância de [Adventure] a partir de um mapa JSON.
  ///
  /// Utiliza o código gerado por `json_serializable`.
  factory Adventure.fromJson(Map<String, dynamic> json) =>
      _$AdventureFromJson(json);

  /// Cria uma instância de [Adventure] a partir de um mapa do banco de dados SQFlite.
  ///
  /// Este método adapta o mapa vindo do SQFlite para o formato esperado
  /// pelo factory `fromJson`.
  factory Adventure.fromMap(Map<String, dynamic> map) {
    // O SQFlite retorna o mapa diretamente no formato que json_serializable espera.
    // Se houvesse necessidade de conversão (ex: booleanos como 0/1), seria feita aqui.
    return Adventure.fromJson(map);
  }

  /// Converte a instância de [Adventure] em um mapa para persistência no SQFlite.
  ///
  /// Utiliza o código gerado por `json_serializable` e remove campos transientes.
  /// O campo `messages` é explicitamente excluído por `json_serializable`
  /// devido à anotação `@JsonKey`.
  Map<String, dynamic> toMap() {
    // O método toJson gerado pelo freezed/json_serializable já faz o trabalho.
    return toJson();
  }
}

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
    @JsonKey(name: 'scenario_title') required String scenarioTitle,

    /// Título específico desta instância da aventura, definido pelo usuário ou gerado.
    @JsonKey(name: 'adventure_title') required String adventureTitle,

    /// o progresso atual na aventura, um valor numerico entre 0.0 e 1.0 representando a porcentagem de progresso ( quantidade de cenas concluidas em relaçao ao total de cenas da aventura)
    @JsonKey(name: 'progress_indicator') double? progressIndicator,

    /// Estado completo do jogo serializado como uma string JSON.
    /// Inclui variáveis, status de personagens, inventário, etc.
    @JsonKey(name: 'game_state') required String gameState,

    /// Timestamp da última vez que a aventura foi jogada ou modificada.
    /// Armazenado como milissegundos desde a época (Unix epoch).
    @JsonKey(name: 'last_played_date') required int lastPlayedDate,

    /// Status de sincronização da aventura com um backend (se aplicável).
    ///
    /// Valores possíveis:
    /// - 0: Apenas local, não sincronizado.
    /// - 1: Sincronizando.
    /// - 2: Sincronizado com sucesso.
    /// - -1: Erro durante a sincronização.
    @JsonKey(name: 'sync_status') @Default(0) int syncStatus,

    /// Lista de mensagens do chat associadas a esta aventura.
    /// Este campo é transiente e não é persistido diretamente na tabela Adventure.
    /// É carregado sob demanda pelo [AdventureRepository].
    // Marcamos para não incluir no JSON/mapa e não esperar do JSON/mapa
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<ChatMessage> messages,
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
    // O SQFlite retorna o mapa com snake_case, mas fromJson espera camelCase
    // (ou o que for definido em @JsonKey(name: ...)).
    // Como adicionamos @JsonKey(name:...), o fromJson gerado já saberá
    // mapear 'scenario_title' para scenarioTitle, etc.
    // Nenhuma conversão manual é necessária aqui.
    return Adventure.fromJson(map);
  }

  /// Converte a instância de [Adventure] em um mapa para persistência no SQFlite.
  ///
  /// Utiliza o código gerado por `json_serializable` e remove campos transientes.
  /// O campo `messages` é explicitamente excluído por `json_serializable`
  /// devido à anotação `@JsonKey`.
  Map<String, dynamic> toMap() {
    // O método toJson gerado saberá usar os nomes definidos em @JsonKey(name:...)
    // e excluirá 'messages' devido a @JsonKey(includeToJson: false).
    return toJson();
  }
}

import 'package:collection/collection.dart';

/// Representa um cenário completo de aventura ou RPG.
///
/// Armazena metadados, componentes narrativos, regras, licença e créditos
/// de forma imutável. Facilita o carregamento, manipulação e persistência
/// dos dados do cenário.
class Scenario {
  /// O título principal do cenário.
  final String title;

  /// O nome do autor ou criador do cenário.
  final String author;

  /// A data de criação ou publicação do cenário.
  final String date;

  /// O gênero principal do cenário (ex: Fantasia, Ficção Científica).
  final String genre;

  /// Descrição textual que define o tom, a atmosfera ou a premissa geral do cenário.
  /// Usado para dar ao jogador uma ideia do tipo de experiência esperada.
  final String ambiance;

  /// Representação opcional da imagem de capa em Base64. Pode ser nulo.
  final String? imageBase64; // Renomeado

  /// Lista de possíveis origens ou antecedentes dos personagens.
  /// Cada mapa pode conter chaves como 'races', 'classes'.
  final List<Map<String, String>> origins;

  /// Lista dos principais pontos da trama.
  /// Cada mapa pode conter chaves como 'when', 'you_need_to', 'otherwise'.
  final List<Map<String, String>> plots;

  /// Lista de cenas específicas, locais ou encontros importantes.
  /// Cada mapa pode conter chaves como 'location', 'character', 'events'.
  final List<Map<String, String>> scenes;

  /// Coleção de ideias, ganchos de aventura, NPCs para expandir o cenário.
  /// Cada mapa pode conter chaves como 'subject', 'action', 'thing', 'quality'.
  final List<Map<String, String>> bankOfIdeas; // Renomeado

  /// Lista de regras específicas ou modificações aplicáveis ao cenário.
  final List<String> rules;

  /// Informações sobre a licença de distribuição do cenário (ex: CC BY-SA 4.0).
  final String license;

  /// Agradecimentos ou créditos a contribuidores ou fontes de inspiração.
  final String credits;

  /// Cria uma nova instância imutável de [Scenario].
  ///
  /// Todos os parâmetros são obrigatórios, exceto [imageBase64].
  const Scenario({
    required this.title,
    required this.author,
    required this.date,
    required this.genre,
    required this.ambiance, // Adicionado
    this.imageBase64, // Renomeado
    required this.origins,
    required this.plots,
    required this.scenes,
    required this.bankOfIdeas, // Renomeado
    required this.rules,
    required this.license,
    required this.credits,
  });

  /// Cria uma instância de [Scenario] a partir de um mapa [json].
  ///
  /// Responsável por extrair valores, converter tipos e validar dados.
  /// Lança [FormatException] se os dados de entrada forem inválidos ou
  /// campos obrigatórios estiverem faltando.
  factory Scenario.fromJson(Map<String, dynamic> json) {
    try {
      // Função auxiliar para converter List<dynamic> para List<Map<String, String>>
      List<Map<String, String>> convertListOfMaps(dynamic list) {
        if (list == null || list is! List) {
          return []; // Retorna lista vazia se for nulo ou não for uma lista
        }
        return List<Map<String, String>>.from(
          list.map((item) {
            if (item is Map) {
              // Converte chaves e valores para String
              return Map<String, String>.from(
                item.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              );
            }
            // Se um item não for um mapa, retorna um mapa vazio ou lança erro
            // Aqui, optamos por retornar um mapa vazio para maior robustez,
            // mas poderia lançar um erro se a estrutura for estritamente necessária.
            // throw FormatException('Item inválido na lista de mapas: $item');
            return <String, String>{};
          }),
        );
      }

      // Função auxiliar para converter List<dynamic> para List<String>
      // ignore: non_constant_identifier_names
      List<String> convertListOfStrings(dynamic list) {
        if (list == null || list is! List) {
          return []; // Retorna lista vazia se for nulo ou não for uma lista
        }
        return List<String>.from(list.map((item) => item.toString()));
      }

      return Scenario(
        title:
            json['title'] as String? ??
            (throw FormatException(
              'Campo "title" ausente ou inválido no JSON',
            )),
        author:
            json['author'] as String? ??
            (throw FormatException(
              'Campo "author" ausente ou inválido no JSON',
            )),
        date:
            json['date'] as String? ??
            (throw FormatException('Campo "date" ausente ou inválido no JSON')),
        genre:
            json['genre'] as String? ??
            (throw FormatException(
              'Campo "genre" ausente ou inválido no JSON',
            )),
        ambiance: // Adicionado
            json['ambiance'] as String? ??
            (throw FormatException(
              'Campo "ambiance" ausente ou inválido no JSON',
            )),
        imageBase64: // Renomeado
            json['imageBase64'] as String?, // Opcional
        origins: convertListOfMaps(json['origins']),
        plots: convertListOfMaps(json['plots']),
        scenes: convertListOfMaps(json['scenes']),
        bankOfIdeas: convertListOfMaps(json['bankOfIdeas']), // Renomeado
        rules: convertListOfStrings(json['rules']),
        license:
            json['license'] as String? ??
            (throw FormatException(
              'Campo "license" ausente ou inválido no JSON',
            )),
        credits:
            json['credits'] as String? ??
            (throw FormatException(
              'Campo "credits" ausente ou inválido no JSON',
            )),
      );
    } catch (e) {
      // Relança a exceção com mais contexto, se necessário, ou apenas relança.
      throw FormatException('Erro ao desserializar Scenario do JSON: $e');
    }
  }

  /// Valida a integridade e consistência dos dados da instância [Scenario].
  ///
  /// Verifica se campos obrigatórios não estão vazios e se listas não são nulas.
  ///
  /// Retorna `true` se válido, `false` caso contrário.
  bool validate() {
    if (title.trim().isEmpty) return false;
    if (author.trim().isEmpty) return false;
    if (date.trim().isEmpty) return false; // Poderia ter validação de formato
    if (genre.trim().isEmpty) return false;
    if (license.trim().isEmpty) return false;
    if (credits.trim().isEmpty) return false;
    // As listas são inicializadas como vazias no fromJson se forem nulas,
    // então a verificação de nulidade não é estritamente necessária aqui,
    // mas é uma boa prática se o construtor padrão pudesse receber nulos.
    // if (origins == null) return false; // Exemplo se fosse necessário
    return true;
  }

  /// Gera uma tabela formatada em Markdown a partir de uma lista de mapas [data].
  ///
  /// Útil para exibir dados como origins, plots, scenes, bankOfIdeas.
  ///
  /// Retorna a string da tabela Markdown ou uma mensagem se [data] estiver vazia.
  String generateMarkdownTable(List<Map<String, String>> data) {
    if (data.isEmpty) {
      return "Nenhum dado disponível.";
    }

    final buffer = StringBuffer();
    // Assume que todas as chaves do primeiro item são os cabeçalhos
    final headers = data.first.keys.toList();

    // Linha de cabeçalho
    buffer.write('| ');
    buffer.write(headers.join(' | '));
    buffer.writeln(' |');

    // Linha separadora
    buffer.write('|');
    for (int i = 0; i < headers.length; i++) {
      buffer.write('------|');
    }
    buffer.writeln();

    // Linhas de dados
    for (final item in data) {
      buffer.write('| ');
      buffer.write(headers.map((header) => item[header] ?? '').join(' | '));
      buffer.writeln(' |');
    }

    return buffer.toString();
  }

  /// Converte a instância de [Scenario] para um mapa JSON.
  ///
  /// Útil para serialização.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'date': date,
      'genre': genre,
      'ambiance': ambiance, // Adicionado
      'imageBase64': imageBase64, // Renomeado
      'origins': origins,
      'plots': plots,
      'scenes': scenes,
      'bankOfIdeas': bankOfIdeas, // Renomeado
      'rules': rules,
      'license': license,
      'credits': credits,
    };
  }

  /// Retorna uma representação em string da instância [Scenario].
  ///
  /// Útil para debugging e logging. Inclui os principais campos.
  @override
  String toString() {
    return 'Scenario(title: $title, author: $author, genre: $genre, date: $date)';
  }

  /// Sobrescreve o operador de igualdade para comparar instâncias de [Scenario].
  ///
  /// Duas instâncias são consideradas iguais se todos os seus atributos forem iguais.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // Helper para comparar listas de mapas
    bool listEquals(
      List<Map<String, String>> list1,
      List<Map<String, String>> list2,
    ) {
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i].length != list2[i].length) return false;
        for (var key in list1[i].keys) {
          if (!list2[i].containsKey(key) || list1[i][key] != list2[i][key]) {
            return false;
          }
        }
      }
      return true;
    }

    return other is Scenario &&
        other.title == title &&
        other.author == author &&
        other.date == date &&
        other.genre == genre &&
        other.ambiance == ambiance && // Adicionado
        other.imageBase64 == imageBase64 && // Renomeado
        listEquals(other.origins, origins) &&
        listEquals(other.plots, plots) &&
        listEquals(other.scenes, scenes) &&
        listEquals(other.bankOfIdeas, bankOfIdeas) && // Renomeado
        ListEquality().equals(other.rules, rules) &&
        other.license == license &&
        other.credits == credits;
  }

  /// Sobrescreve o hashCode para consistência com o operador de igualdade.
  @override
  int get hashCode {
    // Helper para calcular hash de lista de mapas
    int listHashCode(List<Map<String, String>> list) {
      int result = 0;
      for (var map in list) {
        result =
            result * 31 +
            map.entries.fold(
              0,
              (prev, e) => prev * 31 + e.key.hashCode + e.value.hashCode,
            );
      }
      return result;
    }

    // Helper para calcular hash de lista de strings
    int stringListHashCode(List<String> list) {
      return list.fold(0, (prev, element) => prev * 31 + element.hashCode);
    }

    return title.hashCode ^
        author.hashCode ^
        date.hashCode ^
        genre.hashCode ^
        ambiance.hashCode ^ // Adicionado
        imageBase64.hashCode ^ // Renomeado
        listHashCode(origins) ^
        listHashCode(plots) ^
        listHashCode(scenes) ^
        listHashCode(bankOfIdeas) ^ // Renomeado
        stringListHashCode(rules) ^
        license.hashCode ^
        credits.hashCode;
  }
}

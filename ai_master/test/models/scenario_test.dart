import 'dart:convert';
import 'dart:io'; // Import for File operations
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_master/models/scenario.dart'; // Adjust the path if necessary

void main() {
  late String jsonString;
  late Map<String, dynamic> jsonMap;
  late Scenario scenario;

  // Read the actual JSON test file before running tests
  setUpAll(() async {
    final file = File(
      'test/models/scenario_test_data.json',
    ); // Relative path from project root
    jsonString = await file.readAsString();
    jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    scenario = Scenario.fromJson(jsonMap);
  });

  group('Scenario Class Tests', () {
    test(
      'fromJson() should create a Scenario instance from valid JSON file',
      () {
        // Basic check to ensure the object was created
        expect(scenario, isA<Scenario>());

        // Detailed checks based on the known data in the file
        expect(scenario.title, "Dominus & Dragons");
        expect(scenario.author, "Jefferson Pimentel");
        expect(scenario.date, "2025-04-24");
        expect(scenario.genre, "Fantasy");
        expect(
          scenario.ambiance,
          contains("Neste jogo, você é um Aventureiro"),
        ); // Check ambiance
        expect(
          scenario.imageBase64,
          "a string da imagem no formato base64",
        ); // Renomeado
        expect(scenario.origins, isA<List<Map<String, String>>>());
        expect(scenario.origins.length, 20);
        expect(scenario.origins[0]['races'], contains('Tiefling'));
        expect(scenario.plots, isA<List<Map<String, String>>>());
        expect(scenario.plots.length, 20);
        expect(scenario.plots[0]['when'], contains('Um exército de mortos'));
        expect(scenario.scenes, isA<List<Map<String, String>>>());
        expect(scenario.scenes.length, 20);
        expect(
          scenario.scenes[0]['place'],
          contains('Uma pequena vila'),
        ); // Corrected key based on JSON
        expect(scenario.bankOfIdeas, isA<List<Map<String, String>>>());
        expect(scenario.bankOfIdeas.length, 20);
        expect(
          scenario.bankOfIdeas[0]['subject'],
          contains('Um poderoso mago'),
        );
        expect(scenario.rules, isA<List<String>>());
        expect(scenario.rules.length, 6);
        expect(scenario.rules[0], contains('Regra 1'));
        expect(
          scenario.license,
          "Creative Commons Atribuição 4.0 Internacional",
        );
        expect(scenario.credits, "Criado pelo coletivo 'Iniciativa Dominus'.");
      },
    );

    test('fromJson() should handle optional imageBase64 being null', () {
      final Map<String, dynamic> jsonWithoutImage = Map.from(jsonMap);
      jsonWithoutImage.remove('imageBase64'); // Renomeado
      final scenarioWithoutImage = Scenario.fromJson(jsonWithoutImage);

      expect(scenarioWithoutImage.imageBase64, isNull); // Renomeado
    });

    test(
      'fromJson() should throw FormatException for missing required field (title)',
      () {
        final Map<String, dynamic> invalidJson = Map.from(jsonMap);
        invalidJson.remove('title');
        expect(() => Scenario.fromJson(invalidJson), throwsFormatException);
      },
    );

    test(
      'fromJson() should throw FormatException for invalid type (title as int)',
      () {
        final Map<String, dynamic> invalidJson = Map.from(jsonMap);
        invalidJson['title'] = 123; // Invalid type
        expect(() => Scenario.fromJson(invalidJson), throwsFormatException);
      },
    );

    test('fromJson() should handle empty lists correctly', () {
      final Map<String, dynamic> jsonWithEmptyLists = Map.from(jsonMap);
      jsonWithEmptyLists['origins'] = [];
      jsonWithEmptyLists['plots'] = [];
      jsonWithEmptyLists['scenes'] = [];
      jsonWithEmptyLists['bankOfIdeas'] = [];
      jsonWithEmptyLists['rules'] = [];

      final scenarioEmptyLists = Scenario.fromJson(jsonWithEmptyLists);
      expect(scenarioEmptyLists.origins, isEmpty);
      expect(scenarioEmptyLists.plots, isEmpty);
      expect(scenarioEmptyLists.scenes, isEmpty);
      expect(scenarioEmptyLists.bankOfIdeas, isEmpty);
      expect(scenarioEmptyLists.rules, isEmpty);
    });

    test(
      'fromJson() should handle null lists correctly (converting to empty)',
      () {
        final Map<String, dynamic> jsonWithNullLists = Map.from(jsonMap);
        jsonWithNullLists['origins'] = null;
        jsonWithNullLists['rules'] = null;

        final scenarioNullLists = Scenario.fromJson(jsonWithNullLists);
        expect(scenarioNullLists.origins, isEmpty);
        expect(scenarioNullLists.rules, isEmpty);
      },
    );

    test('toJson() should return a valid JSON map', () {
      final generatedJsonMap = scenario.toJson();
      expect(generatedJsonMap, isA<Map<String, dynamic>>());
      expect(generatedJsonMap['title'], scenario.title);
      expect(generatedJsonMap['author'], scenario.author);
      // ... (rest of the assertions for toJson)
      expect(generatedJsonMap['credits'], scenario.credits);

      // Verify individual fields instead of comparing the whole map due to type differences
      // after jsonDecode (List<dynamic> vs List<Map<String, String>>)
      expect(generatedJsonMap['title'], scenario.title);
      expect(generatedJsonMap['author'], scenario.author);
      expect(generatedJsonMap['date'], scenario.date);
      expect(generatedJsonMap['genre'], scenario.genre);
      expect(generatedJsonMap['ambiance'], scenario.ambiance); // Adicionado
      expect(
        generatedJsonMap['imageBase64'],
        scenario.imageBase64,
      ); // Renomeado
      expect(
        generatedJsonMap['origins'],
        scenario.origins,
      ); // Compare lists directly
      expect(generatedJsonMap['plots'], scenario.plots);
      expect(generatedJsonMap['scenes'], scenario.scenes);
      expect(generatedJsonMap['bankOfIdeas'], scenario.bankOfIdeas);
      expect(generatedJsonMap['rules'], scenario.rules);
      expect(generatedJsonMap['license'], scenario.license);
      expect(generatedJsonMap['credits'], scenario.credits);

      // Optional: Check if it can be parsed back into an equivalent Scenario
      final scenarioFromJsonAgain = Scenario.fromJson(generatedJsonMap);
      expect(scenarioFromJsonAgain, equals(scenario));
    });

    test(
      'validate() should return true for a valid scenario loaded from file',
      () {
        expect(scenario.validate(), isTrue);
      },
    );

    test('validate() should return false if title is empty', () {
      final invalidScenario = Scenario(
        title: '', // Invalid
        author: scenario.author,
        date: scenario.date,
        genre: scenario.genre,
        ambiance: scenario.ambiance, // Adicionado
        imageBase64: scenario.imageBase64, // Renomeado
        origins: scenario.origins,
        plots: scenario.plots,
        scenes: scenario.scenes,
        bankOfIdeas: scenario.bankOfIdeas, // Renomeado
        rules: scenario.rules,
        license: scenario.license,
        credits: scenario.credits,
      );
      expect(invalidScenario.validate(), isFalse);
    });

    test('validate() should return false if author is empty', () {
      final invalidScenario = Scenario(
        title: scenario.title,
        author: '  ', // Invalid (only spaces)
        date: scenario.date,
        genre: scenario.genre,
        ambiance: scenario.ambiance, // Adicionado
        imageBase64: scenario.imageBase64, // Renomeado
        origins: scenario.origins,
        plots: scenario.plots,
        scenes: scenario.scenes,
        bankOfIdeas: scenario.bankOfIdeas, // Renomeado
        rules: scenario.rules,
        license: scenario.license,
        credits: scenario.credits,
      );
      expect(invalidScenario.validate(), isFalse);
    });

    // Add similar tests for date, genre, license, credits if needed

    test(
      'generateMarkdownTable() should generate correct markdown for origins',
      () {
        final markdown = scenario.generateMarkdownTable(scenario.origins);
        expect(markdown, startsWith('| races | classes |'));
        expect(markdown, contains('|------|------|'));
        expect(markdown, contains('Tiefling: dada sua origem infernal'));
        expect(markdown, contains('Ladino: matreiro especialista'));
        expect(
          markdown,
          endsWith('|\n'),
        ); // Verify it ends with pipe and newline
        // Count the number of data rows + header + separator
        expect(
          markdown.split('\n').where((line) => line.isNotEmpty).length,
          scenario.origins.length + 2,
        ); // +2 for header and separator
      },
    );

    test(
      'generateMarkdownTable() should generate correct markdown for plots',
      () {
        final markdown = scenario.generateMarkdownTable(scenario.plots);
        expect(markdown, startsWith('| when | you_need_to | otherwise |'));
        expect(markdown, contains('|------|------|------|'));
        expect(markdown, contains('Um exército de mortos avança'));
        expect(markdown, contains('Encontrar um item poderoso'));
        expect(markdown, contains('O mundo será destruído'));
        expect(markdown, endsWith('|\n'));
        expect(
          markdown.split('\n').where((line) => line.isNotEmpty).length,
          scenario.plots.length + 2,
        );
      },
    );

    test('generateMarkdownTable() should return message for empty data', () {
      final markdown = scenario.generateMarkdownTable([]);
      expect(markdown, "Nenhum dado disponível.");
    });

    test(
      'operator == should return true for identical scenarios loaded from same data',
      () {
        final scenario1 = Scenario.fromJson(
          jsonMap,
        ); // Uses the map loaded in setUpAll
        final scenario2 = Scenario.fromJson(jsonMap);
        expect(scenario1 == scenario2, isTrue);
      },
    );

    test('operator == should return false for different scenarios (title)', () {
      final Map<String, dynamic> differentJson = Map.from(jsonMap);
      differentJson['title'] = "Outro Título";
      final scenario1 = scenario; // Use the one from setUpAll
      final scenario2 = Scenario.fromJson(differentJson);
      expect(scenario1 == scenario2, isFalse);
    });

    test(
      'operator == should return false for different scenarios (origins list content)',
      () {
        final Map<String, dynamic> jsonMap1 = Map.from(jsonMap);
        final Map<String, dynamic> jsonMap2 = Map.from(jsonMap);
        // Modify an item in the origins list of the second map
        // Correctly convert List<dynamic> containing Map<String, dynamic>
        // to List<Map<String, String>>
        jsonMap2['origins'] =
            (jsonMap['origins'] as List<dynamic>)
                .map(
                  (item) => Map<String, String>.from(
                    (item as Map).map(
                      (key, value) =>
                          MapEntry(key.toString(), value.toString()),
                    ),
                  ),
                )
                .toList();
        // Now modify the correctly typed list
        jsonMap2['origins'][0] = {
          'races': 'Elfo Modificado', // Modify content
          'classes': 'Guerreiro Modificado', // Modify content
        };

        final scenario1 = Scenario.fromJson(jsonMap1);
        final scenario2 = Scenario.fromJson(jsonMap2);
        expect(scenario1 == scenario2, isFalse);
      },
    );

    test(
      'operator == should return false for different scenarios (rules list content)',
      () {
        final Map<String, dynamic> jsonMap1 = Map.from(jsonMap);
        final Map<String, dynamic> jsonMap2 = Map.from(jsonMap);
        // Modify an item in the rules list of the second map
        jsonMap2['rules'] = List<String>.from(jsonMap['rules']);
        jsonMap2['rules'][0] = "Regra Modificada";

        final scenario1 = Scenario.fromJson(jsonMap1);
        final scenario2 = Scenario.fromJson(jsonMap2);
        expect(scenario1 == scenario2, isFalse);
      },
    );

    test('hashCode should be equal for identical scenarios', () {
      final scenario1 = Scenario.fromJson(jsonMap);
      final scenario2 = Scenario.fromJson(jsonMap);
      expect(scenario1.hashCode, scenario2.hashCode);
    });

    test('hashCode should likely be different for different scenarios', () {
      final Map<String, dynamic> differentJson = Map.from(jsonMap);
      differentJson['title'] = "Outro Título";
      final scenario1 = scenario; // Use the one from setUpAll
      final scenario2 = Scenario.fromJson(differentJson);
      // Note: Hash collisions are possible but unlikely for simple changes.
      expect(scenario1.hashCode, isNot(equals(scenario2.hashCode)));
    });

    test('toString() should return a concise representation', () {
      final expectedString =
          'Scenario(title: ${scenario.title}, author: ${scenario.author}, genre: ${scenario.genre}, date: ${scenario.date})';
      expect(scenario.toString(), expectedString);
    });
  });
}

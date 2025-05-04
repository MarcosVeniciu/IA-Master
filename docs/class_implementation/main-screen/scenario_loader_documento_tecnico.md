# Scenario Loading Technical Document

**Date:** 25/04/2025

## Overview

This document details the technical specification for the `ScenarioLoader` class. Its primary responsibility is to locate, read, and parse JSON files that define the available adventure scenarios within the application. This class acts as a data access layer component, bridging the raw scenario data files (stored typically in the assets folder) and the application's internal `Scenario` model objects. It ensures that only valid scenario data is loaded and made available to other parts of the application, such as the `MainScreenController`. This fulfills requirements RF-009 (Load Scenarios) and RNF-007 (Configurable Scenario Path).

## UML Class Diagram

```mermaid
classDiagram
    class ScenarioLoader {
        +String scenariosFolderPath
        +loadScenarios() List~Scenario~
        -parseScenario(filePath: String) Scenario?
        -validateScenarioData(data: Map~String, dynamic~) bool
    }
    class Scenario {
        +final String title
        +final String author
        +final String date
        +final String genre
        +final String ambiance
        +final String? imageBase64
        +final List~Map~String, String~~ origins
        +final List~Map~String, String~~ plots
        +final List~Map~String, String~~ scenes
        +final List~Map~String, String~~ bankOfIdeas
        +final List~String~ rules
        +final String license
        +final String credits
        +factory Scenario.fromJson(Map~String, dynamic~ json)
        +bool validate()
        +String generateMarkdownTable(List~Map~String, String~~ data)
        %% Constructor omitted for brevity in this context
    }
    class MainScreenController {
        %% ... other attributes and methods
        +loadAvailableScenarios()
    }
    %% AdventureNode removed as it's not directly relevant to ScenarioLoader interaction

    ScenarioLoader ..> Scenario : creates >
    ScenarioLoader ..> dart:io.Directory : uses >
    ScenarioLoader ..> dart:io.File : uses >
    ScenarioLoader ..> dart:convert : uses >
    MainScreenController ..> ScenarioLoader : uses >
    %% Scenario relationship to AdventureNode removed
```

## Methods

### `loadScenarios()`
*   **Signature:** `Future<List<Scenario>> loadScenarios()`
*   **Description:** Asynchronously scans the directory specified by `scenariosFolderPath` for files ending with `.json`. For each JSON file found, it attempts to read, parse, and validate its content using the private helper methods (`_parseScenario`, `_validateScenarioData`). It aggregates all successfully parsed and validated `Scenario` objects into a list. Handles potential errors during file I/O or JSON parsing gracefully (e.g., logging errors, skipping invalid files) as per RF-008.
*   **Algorithmic Notes:**
    1.  Get a reference to the directory using `scenariosFolderPath`.
    2.  List all entities in the directory.
    3.  Filter for files ending with `.json`.
    4.  Iterate through the list of JSON file paths.
    5.  For each path, call `_parseScenario`.
    6.  If `_parseScenario` returns a valid `Scenario` object, add it to the results list.
    7.  Return the list of `Scenario` objects.

### `_parseScenario(String filePath)`
*   **Signature:** `Future<Scenario?> _parseScenario(String filePath)`
*   **Description:** (Private) Reads the content of the file specified by `filePath`. Parses the content as JSON data into a `Map<String, dynamic>`. Calls `_validateScenarioData` to check the structure. If valid, attempts to create a `Scenario` object using its `fromJson` factory constructor. Returns the `Scenario` object on success, or `null` (or throws an exception) if reading, parsing, or validation fails.
*   **Algorithmic Notes:**
    1.  Read file content as a string using `dart:io`.
    2.  Decode the string into a `Map<String, dynamic>` using `dart:convert`.
    3.  Call `_validateScenarioData` with the map.
    4.  If valid, call `Scenario.fromJson(map)`.
    5.  Return the created `Scenario` or `null`/throw on error.
    6.  Implement error handling (try-catch) for file reading and JSON decoding.

### `_validateScenarioData(Map<String, dynamic> data)`
*   **Signature:** `bool _validateScenarioData(Map<String, dynamic> data)`
*   **Description:** (Private) Checks if the provided `data` map contains all the mandatory fields required to construct a valid `Scenario` object using `Scenario.fromJson`. This includes fields like `title`, `author`, `date`, `genre`, `ambiance`, `origins`, `plots`, `scenes`, `bankOfIdeas`, `rules`, `license`, and `credits`. It primarily relies on the `Scenario.fromJson` constructor itself to perform the detailed validation and type checking, potentially catching exceptions thrown by it. Returns `true` if the basic structure seems plausible (e.g., required keys exist), `false` otherwise. A more robust validation might happen within `Scenario.fromJson`.
*   **Algorithmic Notes:**
    1.  Check for the presence and non-nullity of essential keys required by `Scenario.fromJson` (e.g., `title`, `author`, `date`, `genre`, `ambiance`, `origins`, `plots`, `scenes`, `bankOfIdeas`, `rules`, `license`, `credits`). Note: `imageBase64` is optional.
    2.  Optionally, perform basic type checks (e.g., check if `origins` is a List).
    3.  Return `true` if basic checks pass, `false` otherwise. The main validation occurs within `Scenario.fromJson`.

## Implementation Details

*   **Language:** Dart
*   **Libraries/Modules:**
    *   `dart:io`: Used for file system operations, specifically reading files (`File.readAsString()`) and listing directory contents (`Directory.list()`). Rationale: Standard Dart library for platform-native I/O.
    *   `dart:convert`: Used for decoding JSON strings into Dart objects (`jsonDecode`). Rationale: Standard Dart library for JSON manipulation.
    *   `package:path/path.dart` (Optional but recommended): For robust path manipulation across different operating systems. Rationale: Simplifies joining path segments and handling separators.
*   **Models:**
    *   `Scenario`: The data model class representing a single adventure scenario (defined in `ai_master/lib/models/scenario.dart`). `ScenarioLoader` depends on this class and its `fromJson` factory constructor.

## Change History

| Date         | Author        | Description                       |
|--------------|---------------|-----------------------------------|
| 25/04/2025   | Roo (AI)      | Initial document creation.        |

## Implementation History

[ID: DOC_UPDATE_202504251613] 25/04/2025 16:13 - Correção da Documentação do ScenarioLoader
Reason: Alinhar a documentação com a estrutura correta da classe `Scenario` após atualizações. O diagrama UML e a descrição da validação estavam desatualizados.
Changes:
 - Corrigida a definição da classe `Scenario` no diagrama UML interno.
 - Removida a classe `AdventureNode` do diagrama UML interno por irrelevância.
 - Atualizada a descrição e as notas algorítmicas do método `_validateScenarioData` para refletir os campos corretos da classe `Scenario`.
Future Modification Guidelines:
 - Manter este documento sincronizado com a implementação real do `ScenarioLoader` e a estrutura do `Scenario`.

[ID: 202504251452] 25/04/2025 14:52 - Implementação inicial da classe ScenarioLoader
Reason: Criação da classe para carregar dados de cenários de arquivos JSON, conforme especificado nos requisitos RF-009 e RNF-007.
Changes:
 - Criação do arquivo `ai_master/lib/services/scenario_loader.dart`.
 - Implementação dos métodos `loadScenarios`, `_parseScenario`, `_validateScenarioData`.
 - Adição de dependências `dart:io` e `dart:convert`.
 - Integração com o modelo `Scenario`.
Future Modification Guidelines:
 - Manter a validação de dados (`_validateScenarioData`) atualizada com quaisquer mudanças no formato do `Scenario`.
 - Considerar otimizações de I/O se o número de cenários crescer significativamente.
 - Garantir que o tratamento de erros seja robusto para arquivos malformados ou ausentes.

# Plano de Refatoração: Introdução do Atributo `adventureTitle`

**1. Metas e Escopo**

*   **Meta Principal:** Refatorar o sistema para introduzir um novo atributo `adventureTitle` na entidade `Adventure`, distinto do `scenarioTitle` existente.
*   **Escopo:**
    *   Modificar o modelo de dados `Adventure` (código Dart).
    *   Atualizar o schema do banco de dados SQFlite e implementar a migração necessária.
    *   Garantir que a camada de persistência (`AdventureRepository`) lide com o novo atributo.
    *   Atualizar a interface do usuário (`OngoingAdventureCard`) para exibir `adventureTitle` como título principal e `scenarioTitle` como subtítulo.
    *   Atualizar a documentação relevante (UML, Schema DB, Requisitos).
*   **Fora do Escopo:**
    *   Alterações em outras funcionalidades não diretamente relacionadas à exibição ou persistência do título da aventura.
    *   Criação de mecanismos na UI para o *usuário* editar o `adventureTitle` (isso seria uma feature separada).

**2. Entradas e Artefatos**

*   **Arquivos de Código a Modificar:**
    *   `ai_master/lib/models/adventure.dart`
    *   `ai_master/lib/services/database_helper.dart`
    *   `ai_master/lib/features/main_screen/widgets/ongoing_adventure_card.dart`
*   **Arquivos de Código a Regenerar:**
    *   `ai_master/lib/models/adventure.freezed.dart`
    *   `ai_master/lib/models/adventure.g.dart`
*   **Arquivos de Documentação a Modificar:**
    *   `docs/uml_diagram/main-screen/ia-master-adventure.md`
    *   `docs/database_architecture/main-screen/ia-master-adventure-schema.md`
    *   `docs/requirements_analysis/ia-master-main-screen-srs.md`
*   **Ferramentas:**
    *   Flutter SDK
    *   `build_runner` (para geração de código `freezed`)

**3. Metodologia (Passos Detalhados)**

1.  **Modelo de Dados (`ai_master/lib/models/adventure.dart`):**
    *   Adicionar o campo `required String adventureTitle` dentro da factory `Adventure`.
    *   Executar o comando `flutter pub run build_runner build --delete-conflicting-outputs` no terminal para regenerar os arquivos `.freezed.dart` e `.g.dart`.

2.  **Banco de Dados (`ai_master/lib/services/database_helper.dart`):**
    *   Incrementar a constante `_dbVersion` para `3`.
    *   Descomentar o parâmetro `onUpgrade: _onUpgrade` dentro da função `openDatabase` em `_initDb`.
    *   Implementar a função `_onUpgrade(Database db, int oldVersion, int newVersion)`:
        ```dart
        Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 3) {
            // Abordagem segura para adicionar coluna NOT NULL no SQLite:
            // 1. Renomear tabela antiga
            await db.execute('ALTER TABLE Adventure RENAME TO Adventure_old;');

            // 2. Criar nova tabela com a coluna adventure_title NOT NULL
            await db.execute('''
              CREATE TABLE Adventure (
                  id TEXT PRIMARY KEY NOT NULL,
                  scenario_title TEXT NOT NULL,
                  adventure_title TEXT NOT NULL, -- Nova coluna obrigatória
                  progress_indicator REAL,
                  game_state TEXT NOT NULL,
                  last_played_date INTEGER NOT NULL,
                  sync_status INTEGER NOT NULL DEFAULT 0
              );
            ''');
             // Recriar índice (se necessário, dependendo da versão do SQLite, pode ser recriado automaticamente)
            await db.execute('''
              CREATE INDEX idx_adventure_last_played ON Adventure(last_played_date DESC);
            ''');


            // 3. Copiar dados, usando scenario_title como valor inicial para adventure_title
            await db.execute('''
              INSERT INTO Adventure (id, scenario_title, adventure_title, progress_indicator, game_state, last_played_date, sync_status)
              SELECT id, scenario_title, scenario_title, progress_indicator, game_state, last_played_date, sync_status
              FROM Adventure_old;
            ''');

            // 4. Remover tabela antiga
            await db.execute('DROP TABLE Adventure_old;');

            // Migração para ChatMessage (se necessário no futuro, adicionar aqui)
            // Exemplo: Adicionar coluna se migrando de versão < X
            // await db.execute('ALTER TABLE ChatMessage ADD COLUMN new_chat_field TEXT;');

          }
          // Adicionar mais blocos 'if (oldVersion < X)' para futuras migrações
        }
        ```
    *   Atualizar a instrução `CREATE TABLE Adventure` dentro do método `_onCreate` para incluir `adventure_title TEXT NOT NULL` na posição correta, garantindo que novas instalações do app já tenham o schema correto.

3.  **Camada de Persistência (`ai_master/lib/repositories/adventure_repository.dart`):**
    *   Nenhuma alteração manual é esperada neste arquivo. A regeneração do código `freezed` deve atualizar os métodos `toMap()` e `fromJson()`/`fromMap()` para incluir o novo campo automaticamente.

4.  **Interface do Usuário (`ai_master/lib/features/main_screen/widgets/ongoing_adventure_card.dart`):**
    *   Localizar o widget `Text` que atualmente exibe `adventure.scenarioTitle` (linha ~96). Alterá-lo para exibir `adventure.adventureTitle`.
    *   Adicionar um novo widget `Text` logo abaixo do título principal.
        *   Conteúdo: `adventure.scenarioTitle` (talvez prefixado com "Cenário: " ou similar).
        *   Estilo: Usar um `TextStyle` com `fontSize` menor (ex: 12), `color` mais suave (ex: `Colors.white70`), e possivelmente `fontStyle: FontStyle.italic`. Ajustar conforme o design desejado.
        *   Adicionar `SizedBox(height: 4)` ou similar entre os dois textos para espaçamento.

5.  **Documentação:**
    *   **`docs/uml_diagram/main-screen/ia-master-adventure.md`:**
        *   No diagrama Mermaid, adicionar a linha: `+String adventureTitle // Título específico da instância da aventura`
        *   Na seção "Atributos", adicionar: `*   adventureTitle: Título específico definido para esta instância da aventura.`
    *   **`docs/database_architecture/main-screen/ia-master-adventure-schema.md`:**
        *   Na seção "Fields", adicionar a linha: `- adventure_title: TEXT (NOT NULL, Título específico da instância da aventura)`
    *   **`docs/requirements_analysis/ia-master-main-screen-srs.md`:**
        *   Na tabela de Requisitos Funcionais, atualizar a descrição do `RF-002` para: "Cada card mostra o título específico da aventura (`adventureTitle`), o título do cenário base (`scenarioTitle`) como subtítulo, gênero, uma barra de progresso visual, informação de "Last access" e um botão/ícone "Play"."

**4. Entregáveis**

*   Versões atualizadas dos arquivos de código listados em "Arquivos de Código a Modificar".
*   Versões atualizadas dos arquivos de documentação listados em "Arquivos de Documentação a Modificar".
*   Arquivos `.freezed.dart` e `.g.dart` regenerados.

**5. Visualização (Exemplo de Alteração na UI)**

*   **Antes (em `ongoing_adventure_card.dart`):**
    ```dart
    Text(
      adventure.scenarioTitle, // Título principal era o do cenário
      // ... estilos ...
    ),
    // ... resto do card ...
    ```
*   **Depois (em `ongoing_adventure_card.dart`):**
    ```dart
    Text(
      adventure.adventureTitle, // Novo título principal
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
      ),
    ),
    const SizedBox(height: 4), // Espaçamento
    Text(
      adventure.scenarioTitle, // Título do cenário como subtítulo
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.8), // Cor mais suave
        // fontStyle: FontStyle.italic, // Opcional
        shadows: const [Shadow(blurRadius: 1.0, color: Colors.black45)],
      ),
    ),
    const Spacer(), // Empurra o resto para baixo
    // ... barra de progresso, data ...
    ```

**6. Riscos e Mitigação**

*   **Risco:** Erro na migração do banco de dados (SQL inválido, falha ao copiar dados).
    *   **Mitigação:** Usar a abordagem de renomear/criar/copiar/dropar no `_onUpgrade`, que é mais segura para SQLite. Testar a migração em um emulador/dispositivo de desenvolvimento antes de aplicar em produção. Verificar os logs do aplicativo em caso de falha na inicialização do banco.
*   **Risco:** Falha na geração de código (`build_runner`).
    *   **Mitigação:** Garantir que não há erros de sintaxe no modelo. Executar `flutter clean` antes de `build_runner`. Verificar os logs de erro do `build_runner`.
*   **Risco:** A interface do usuário (subtítulo) não fica visualmente agradável.
    *   **Mitigação:** Ajustar o `TextStyle` (tamanho, cor, peso da fonte) do subtítulo iterativamente até atingir o resultado desejado. Testar em diferentes tamanhos de tela.
*   **Risco:** Esquecer de atualizar a documentação.
    *   **Mitigação:** Incluir a atualização da documentação como um passo explícito no plano e revisar os documentos listados após a implementação do código.

**7. Histórico de Mudanças**

| Data         | Autor    | Descrição das Mudanças no Plano                                  |
| :----------- | :------- | :--------------------------------------------------------------- |
| 2025-05-03   | Roo (AI) | Versão inicial do plano de refatoração para `adventureTitle`. |

**8. Histórico de Implementação**

*(Esta seção será preenchida conforme a implementação for realizada)*
| Data         | Autor    | Descrição da Implementação                                                                                                                                                              |
| :----------- | :------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2025-05-03   | Roo (AI) | Implementado o plano: Modificado Adventure model, DatabaseHelper (v3, _onUpgrade), OngoingAdventureCard UI. Regenerado código freezed. Atualizado UML, Schema DB e SRS. |
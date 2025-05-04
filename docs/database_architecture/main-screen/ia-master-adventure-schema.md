# Adventure Schema

## Fields
- id: TEXT (PRIMARY KEY NOT NULL, Identificador único da aventura, pode ser um UUID)
- scenario_title: TEXT (NOT NULL, Título do cenário sendo jogado, conforme RF-002)
- progress_indicator: TEXT (NULLABLE, String descritiva do progresso, conforme RF-002)
- game_state: TEXT (NOT NULL, String JSON contendo o estado atual do jogo, variáveis, etc., conforme RNF-008)
- last_played_date: INTEGER (NOT NULL, Timestamp Unix da última interação, para ordenação)
- sync_status: INTEGER (NOT NULL DEFAULT 0, Otimização: 0=local, 1=sincronizado, 2=modificado localmente)

## Relationships
- **Implícito:** Baseado em um `Scenario` (identificado por `scenario_title`).
- **1:N:** Uma `Adventure` pode ter muitos `ChatMessage`s. A ligação é feita via `ChatMessage.adventure_id` referenciando `Adventure.id`.

## Mobile Optimizations
- **Índice:** Criar um índice em `last_played_date` para buscar e ordenar eficientemente as aventuras na seção "Ongoing Adventures".
- **Sincronização:** O campo `sync_status` facilita a implementação de estratégias de sincronização (delta sync) se o backup/sincronização online for adicionado futuramente.
- **Armazenamento de Estado (game_state):** Armazenar como JSON (TEXT) oferece flexibilidade para evolução do estado do jogo sem alterar o esquema do banco de dados. Para dados muito grandes ou binários, BLOB poderia ser uma alternativa, mas JSON é geralmente preferível para dados estruturados.
- **Chave Primária:** Usar um UUID (armazenado como TEXT) para `id` garante unicidade mesmo em cenários offline ou distribuídos.
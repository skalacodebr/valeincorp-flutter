# 📊 Estrutura de Dados - Empreendimentos, Unidades e Vagas

## 🏢 Hierarquia de Dados

```
EMPRENDIMENTO
  ├── Endereço (empreendimentos_endereco)
  ├── Status (empreendimentos_status)
  ├── Tipo (tipo_empreendimento)
  ├── Áreas de Lazer (empreendimentos_areas_lazer)
  ├── Imagens/Vídeos (empreendimentos_imagens_arquivos)
  ├── Documentos (empreendimentos_documentos)
  └── TORRES (empreendimentos_tores)
       ├── Exceções por Andar (empreendimentos_tores_excessao)
       ├── UNIDADES (empreendimentos_unidades)
       │    ├── Vagas de Garagem (empreendimentos_unidades_vagas_garem)
       │    └── Medidas Dinâmicas (medidas_unidades)
       ├── Fotos das Unidades (empreendimentos_unidades_fotos)
       └── Vídeos das Unidades (empreendimentos_unidades_videos)
```

---

## 📋 TABELAS PRINCIPAIS

### 1. **empreendimentos** (Tabela Principal)
**Localização:** `database/migrations/0001_01_01_000000_create_base_tables.php` (linha 270)

**Campos principais:**
- `id` - ID único
- `nome` - Nome do empreendimento
- `tipo_empreendimento_id` - FK para tipo (apartamento, casa, etc.)
- `tipo_unidades_id` - FK para tipo de unidade
- `numero_total_unidade` - Total de unidades
- `tamanho_total_comum_unidade_metros_quadrados` - Área comum total
- `area_lazer` - Boolean (tem área de lazer?)
- `area_total` - Área total do empreendimento
- `observacoes` - Texto livre
- `empreendimentos_status_id` - Status (em construção, lançamento, etc.)
- `data_entrega` - Data prevista (formato MM-AA)
- `equipe_usuarios_id` - Responsável pelo empreendimento
- `imagem_empreendimento` - URL da imagem principal
- `evolucao` - JSON com evoluções da obra
- `catalogo_pdf_url` - URL do catálogo PDF
- `memorial_descritivo_url` - URL do memorial descritivo

**Model:** `app/Models/Empreendimento.php`

---

### 2. **empreendimentos_tores** (Torres/Blocos)
**Localização:** Migração linha 324

**Campos:**
- `id` - ID único
- `empreendimentos_id` - FK para empreendimento
- `nome` - Nome da torre (ex: "Torre A", "Bloco 1")
- `numero_andares` - Quantidade de andares
- `unidades_por_andar` - Quantidade padrão de unidades por andar

**Relacionamentos:**
- `empreendimento()` - Pertence a um Empreendimento
- `unidades()` - Tem muitas Unidades
- `excessoes()` - Tem exceções por andar
- `fotosUnidades()` - Fotos relacionadas às unidades
- `videosUnidades()` - Vídeos relacionados às unidades
- `vagasGaragem()` - Vagas de garagem da torre

**Model:** `app/Models/EmpreendimentoTorre.php`

**Campos calculados:**
- `unidades_por_andar` - Array com unidades por andar (considerando exceções)
- `total_unidades` - Total de unidades na torre

---

### 3. **empreendimentos_tores_excessao** (Exceções por Andar)
**Localização:** Migração linha 333

**Campos:**
- `id` - ID único
- `empreendimentos_tores_id` - FK para torre
- `andar` - Número do andar com exceção
- `quantidade_unidades` - Quantidade de unidades neste andar específico

**Uso:** Permite definir quantidades diferentes de unidades por andar (ex: térreo tem 2 unidades, demais andares têm 4)

**Model:** `app/Models/EmpreendimentoTorreExcessao.php`

---

### 4. **empreendimentos_unidades** ⭐ (TABELA PRINCIPAL DE UNIDADES)
**Localização:** Migração linha 341

**Campos:**
- `id` - ID único
- `empreendimentos_tores_id` - FK para torre (OBRIGATÓRIO)
- `numero_andar_apartamento` - Número do andar
- `numero_apartamento` - Número da unidade (ex: "101", "202")
- `tamanho_unidade_metros_quadrados` - Área da unidade em m²
- `valor` - Valor da unidade (decimal 15,2)
- `numero_quartos` - Quantidade de quartos
- `numero_suites` - Quantidade de suítes
- `numero_banheiros` - Quantidade de banheiros
- `status_unidades_id` - FK para status (Disponível, Reservada, Vendida)
- `observacao` - Observações sobre a unidade
- `posicao` - Posição/insolação (ex: "Sul", "Norte", "Leste")

**Relacionamentos:**
- `torre()` - Pertence a uma Torre
- `vagas()` - Tem muitas Vagas de Garagem
- `medidas()` - Tem muitas Medidas Dinâmicas

**Model:** `app/Models/EmpreendimentoUnidade.php`

**Controller:** `app/Http/Controllers/API/EmpreendimentoUnidadeController.php`

**Endpoints:**
- `POST /api/empreendimentos/{torre_id}/unidades` - Criar unidade
- `GET /api/empreendimentos/{torre_id}/unidades/{id}` - Ver detalhes
- `PUT /api/empreendimentos/{torre_id}/unidades/{id}` - Atualizar
- `DELETE /api/empreendimentos/{torre_id}/unidades/{id}` - Deletar

---

### 5. **empreendimentos_unidades_vagas_garem** (Vagas de Garagem)
**Localização:** Migração linha 357

**Campos:**
- `id` - ID único
- `unidade_id` - FK para unidade (OBRIGATÓRIO)
- `numero` - Número da vaga (ex: "V01", "V02")
- `tipo` - Tipo da vaga (ex: "Coberta", "Descoberta", "Box")

**Observação:** A migração original tem campos diferentes do Model atual. O Model tem:
- `empreendimentos_tores_id` - FK para torre
- `numero_vaga` - Número da vaga
- `cobertura` - Boolean (coberta?)
- `tipo_vaga` - Tipo da vaga
- `area_total` - Área da vaga
- `pavimento` - Pavimento da vaga
- `observacoes` - Observações
- `status` - Status da vaga

**Model:** `app/Models/EmpreendimentoUnidadeVagaGaragem.php`

**Relacionamentos:**
- `unidade()` - Pertence a uma Unidade
- `torre()` - Pertence a uma Torre

---

### 6. **medidas_unidades** (Medidas Dinâmicas)
**Localização:** Migração linha 365

**Campos:**
- `id` - ID único
- `unidade_id` - FK para unidade (OBRIGATÓRIO)
- `tipo_medida_unidade_id` - FK para tipo de medida
- `valor` - Valor da medida (decimal 10,2)

**Uso:** Permite criar medidas customizadas por unidade:
- Área Privativa
- Área Total
- Área Construída
- Área Útil
- etc.

**Model:** `app/Models/MedidaUnidade.php`

**Tabela relacionada:** `tipos_medida_unidades` - Define os tipos de medidas disponíveis

---

### 7. **status_unidades** (Status das Unidades)
**Localização:** Migração linha 72

**Campos:**
- `id` - ID único
- `nome` - Nome do status (ex: "Disponível", "Reservada", "Vendida")
- `cor` - Cor para exibição (ex: "#10B981" para verde)

**Model:** `app/Models/StatusUnidade.php`

---

### 8. **empreendimentos_unidades_fotos** (Fotos das Unidades)
**Localização:** Migração linha 373

**Campos:**
- `id` - ID único
- `empreendimentos_tores_id` - FK para torre
- `url` - URL da foto
- `legenda` - Legenda da foto
- `categoria_foto_id` - FK para categoria (ex: "Planta Baixa", "Fachada")

**Model:** `app/Models/EmpreendimentoUnidadeFoto.php`

**Tabela relacionada:** `categorias_fotos` - Categorias de fotos

---

### 9. **empreendimentos_unidades_videos** (Vídeos das Unidades)
**Localização:** Migração linha 382

**Campos:**
- `id` - ID único
- `empreendimentos_tores_id` - FK para torre
- `url` - URL do vídeo
- `video_path` - Caminho do arquivo
- `video_url` - URL pública do vídeo
- `titulo` - Título do vídeo
- `descricao` - Descrição
- `tipo` - Tipo do vídeo
- `original_name` - Nome original do arquivo
- `file_size` - Tamanho do arquivo
- `mime_type` - Tipo MIME

**Model:** `app/Models/EmpreendimentoUnidadeVideo.php`

---

## 🔗 RELACIONAMENTOS ENTRE TABELAS

### Fluxo de Dados:

```
1. EMPREENDIMENTO
   ↓
2. TORRE (empreendimentos_tores)
   ↓
3. UNIDADE (empreendimentos_unidades) ← DADOS PRINCIPAIS AQUI
   ├──→ VAGAS (empreendimentos_unidades_vagas_garem)
   └──→ MEDIDAS (medidas_unidades)
```

### Chaves Estrangeiras:

- `empreendimentos.tores` → `empreendimentos_tores.empreendimentos_id`
- `empreendimentos_tores.unidades` → `empreendimentos_unidades.empreendimentos_tores_id`
- `empreendimentos_unidades.vagas` → `empreendimentos_unidades_vagas_garem.unidade_id`
- `empreendimentos_unidades.medidas` → `medidas_unidades.unidade_id`
- `empreendimentos_unidades.status` → `status_unidades.id`

---

## 📍 ONDE OS DADOS SÃO SALVOS

### 1. **Criação de Unidade:**
**Controller:** `app/Http/Controllers/API/EmpreendimentoUnidadeController.php`
**Método:** `store()`
**Endpoint:** `POST /api/empreendimentos/{torre_id}/unidades`

**Processo:**
1. Valida os dados da unidade
2. Cria registro em `empreendimentos_unidades`
3. Sincroniza vagas de garagem (`syncVagas()`)
4. Retorna unidade com relacionamentos carregados

### 2. **Consulta de Unidades:**
**Endpoint:** `GET /api/empreendimentos/{torre_id}/unidades`
**Endpoint:** `GET /api/empreendimentos/{torre_id}/unidades/{id}`

**Carrega:**
- Torre e empreendimento
- Vagas de garagem
- Medidas dinâmicas
- Status da unidade

### 3. **Dados no Frontend (Flutter):**
**Service:** `flutter/lib/services/imoveis_service.dart`
**Métodos:**
- `getTorres(int imovelId)` - Busca torres do empreendimento
- `getUnidades(int torreId)` - Busca unidades de uma torre

---

## 📊 RESUMO DAS TABELAS

| Tabela | Propósito | Registros por Empreendimento |
|--------|-----------|------------------------------|
| `empreendimentos` | Dados gerais | 1 |
| `empreendimentos_tores` | Torres/Blocos | 1-N |
| `empreendimentos_unidades` | **Unidades** | N (depende das torres) |
| `empreendimentos_unidades_vagas_garem` | Vagas de garagem | N (1-N por unidade) |
| `medidas_unidades` | Medidas customizadas | N (1-N por unidade) |
| `status_unidades` | Status disponíveis | Fixo (3-5 registros) |
| `empreendimentos_unidades_fotos` | Fotos | N (por torre) |
| `empreendimentos_unidades_videos` | Vídeos | N (por torre) |

---

## 🎯 PONTOS IMPORTANTES

1. **Unidades são salvas em:** `empreendimentos_unidades`
2. **Vagas são salvas em:** `empreendimentos_unidades_vagas_garem` (relacionadas à unidade)
3. **Medidas dinâmicas:** `medidas_unidades` (permite flexibilidade)
4. **Hierarquia:** Empreendimento → Torre → Unidade → Vagas/Medidas
5. **Status:** Controlado por `status_unidades_id` na tabela `empreendimentos_unidades`

---

## 🔍 QUERIES ÚTEIS

### Buscar todas as unidades de um empreendimento:
```php
$empreendimento = Empreendimento::with('torres.unidades.vagas', 'torres.unidades.medidas')->find($id);
```

### Buscar unidades disponíveis:
```php
$unidadesDisponiveis = EmpreendimentoUnidade::whereHas('status', function($q) {
    $q->where('nome', 'Disponível');
})->get();
```

### Contar unidades por status:
```php
EmpreendimentoUnidade::join('status_unidades', 'empreendimentos_unidades.status_unidades_id', '=', 'status_unidades.id')
    ->groupBy('status_unidades.nome')
    ->selectRaw('status_unidades.nome, count(*) as total')
    ->get();
```

---

**Última atualização:** Janeiro 2025


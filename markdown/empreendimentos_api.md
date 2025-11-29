# Testes de Integração - API Empreendimentos

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api`

**Headers Comuns:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

---

## Listar Empreendimentos

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos?search=Residencial&per_page=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "data": [
    {
      "id": 7,
      "nome": "Residencial Alto Padrão",
      "tipo_empreendimento_id": 2,
      "tipo_unidades_id": 1,
      "numero_total_unidade": 100,
      "tamanho_total_unidade_metros_quadrados": 8000.5,
      "area_lazer": true,
      "observacoes": "Próximo ao parque",
      "empreendimentos_status_id": 1,
      "equipe_usuarios_id": 4,"memorial_descritivo_base64": "<string_base64_memorial>",
      "catalogo_pdf_base64": "<string_base64_catalogo>",
      "torres": [ /* array de torres com excessoes */ ],
      "areasLazer": [ /* array de áreas de lazer */ ],
      "endereco": { /* objeto endereço */ },
      "imagensArquivos": [ /* array de imagens e arquivos */ ]
    }
  ],
  "links": { /* paginação */ },
  "meta": { /* paginação */ }
}
```

---

## Obter Empreendimento por ID

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/7" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "id": 7,
  "nome": "Residencial Alto Padrão",
  "tipo_empreendimento_id": 2,
  "tipo_unidades_id": 1,
  "numero_total_unidade": 100,
  "tamanho_total_unidade_metros_quadrados": 8000.5,
  "area_lazer": true,
  "observacoes": "Próximo ao parque",
  "empreendimentos_status_id": 1,
  "equipe_usuarios_id": 4,"memorial_descritivo_base64": "<string_base64_memorial>",
      "catalogo_pdf_base64": "<string_base64_catalogo>",
  "torres": [ /* array de torres com excessoes */ ],
  "areasLazer": [ /* array de áreas de lazer */ ],
  "endereco": { /* objeto endereço */ },
  "imagensArquivos": [ /* array de imagens e arquivos */ ]
}
```

---

## Criar Empreendimento

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Residencial Vista Mar",
    "tipo_empreendimento_id": 3,
    "tipo_unidades_id": 2,
    "numero_total_unidade": 50,
    "tamanho_total_unidade_metros_quadrados": 4000.0,
    "area_lazer": false,
    "observacoes": "Vista para o mar",
    "empreendimentos_status_id": 2,
    "equipe_usuarios_id": 5,
    "memorial_descritivo_base64": "<string_base64_memorial>",
    "catalogo_pdf_base64": "<string_base64_catalogo>"
  }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 8,
  "nome": "Residencial Vista Mar",
  "tipo_empreendimento_id": 3,
  "tipo_unidades_id": 2,
  "numero_total_unidade": 50,
  "tamanho_total_unidade_metros_quadrados": 4000.0,
  "area_lazer": false,
  "observacoes": "Vista para o mar",
  "empreendimentos_status_id": 2,
  "equipe_usuarios_id": 5,
    "memorial_descritivo_base64": "<string_base64_memorial>",
    "catalogo_pdf_base64": "<string_base64_catalogo>","memorial_descritivo_base64": "<string_base64_memorial>",
      "catalogo_pdf_base64": "<string_base64_catalogo>",
  "created_at": "2025-05-26T16:00:00Z",
  "updated_at": "2025-05-26T16:00:00Z"
}
```

---

## Atualizar Empreendimento

### Requisição

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/8" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Residencial Vista Mar Atualizado",
    "tipo_empreendimento_id": 3,
    "tipo_unidades_id": 2,
    "numero_total_unidade": 60,
    "tamanho_total_unidade_metros_quadrados": 4500.0,
    "area_lazer": true,
    "observacoes": "Inclui piscina",
    "empreendimentos_status_id": 1,
    "equipe_usuarios_id": 5,
    "memorial_descritivo_base64": "<string_base64_memorial>",
    "catalogo_pdf_base64": "<string_base64_catalogo>"
  }'
```

### Resposta Esperada (200 OK)

```json
{
  "id": 8,
  "nome": "Residencial Vista Mar Atualizado",
  "tipo_empreendimento_id": 3,
  "tipo_unidades_id": 2,
  "numero_total_unidade": 60,
  "tamanho_total_unidade_metros_quadrados": 4500.0,
  "area_lazer": true,
  "observacoes": "Inclui piscina",
  "empreendimentos_status_id": 1,
  "equipe_usuarios_id": 5,
    "memorial_descritivo_base64": "<string_base64_memorial>",
    "catalogo_pdf_base64": "<string_base64_catalogo>","memorial_descritivo_base64": "<string_base64_memorial>",
      "catalogo_pdf_base64": "<string_base64_catalogo>",
  "created_at": "2025-05-26T16:00:00Z",
  "updated_at": "2025-05-27T09:00:00Z"
}
```

---

## Excluir Empreendimento

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/8" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Empreendimento removido com sucesso." }
```


---

## CRUD de Torres

### Criar Torre

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/7/torres" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Bloco A",
    "numero_andares": 12,
    "quantidade_unidades_andar": 4
  }'
```

**Resposta Esperada (201 Created)**

```json
{
  "id": 20,
  "empreendimentos_id": 7,
  "nome": "Bloco A",
  "numero_andares": 12,
  "quantidade_unidades_andar": 4,
  "created_at": "2025-05-26T16:30:00Z",
  "updated_at": "2025-05-26T16:30:00Z"
}
```

### Atualizar Torre

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/20" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Bloco A1",
    "numero_andares": 14,
    "quantidade_unidades_andar": 4
  }'
```

**Resposta Esperada (200 OK)**

```json
{
  "id": 20,
  "empreendimentos_id": 7,
  "nome": "Bloco A1",
  "numero_andares": 14,
  "quantidade_unidades_andar": 4,
  "created_at": "2025-05-26T16:30:00Z",
  "updated_at": "2025-05-27T09:30:00Z"
}
```

### Excluir Torre

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/20" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

**Resposta Esperada (200 OK)**

```json
{ "message": "Torre removida com sucesso." }
```

---

## CRUD de Exceções de Torres

### Criar Exceção

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/20/excessoes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "numero_andar": 5,
    "quantidade_unidades_andar": 2
  }'
```

**Resposta Esperada (201 Created)**

```json
{
  "id": 100,
  "empreendimentos_tores_id": 20,
  "numero_andar": 5,
  "quantidade_unidades_andar": 2,
  "created_at": "2025-05-26T17:00:00Z",
  "updated_at": "2025-05-26T17:00:00Z"
}
```

### Atualizar Exceção

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/excessoes/100" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "numero_andar": 5,
    "quantidade_unidades_andar": 3
  }'
```

**Resposta Esperada (200 OK)**

```json
{
  "id": 100,
  "empreendimentos_tores_id": 20,
  "numero_andar": 5,
  "quantidade_unidades_andar": 3,
  "created_at": "2025-05-26T17:00:00Z",
  "updated_at": "2025-05-27T10:00:00Z"
}
```

### Excluir Exceção

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/excessoes/100" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

**Resposta Esperada (200 OK)**

```json
{ "message": "Exceção removida com sucesso." }
```

---

## CRUD de Áreas de Lazer

### Criar Área de Lazer

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/7/areas-lazer" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{ "tipo_area_lazer_id": 2 }'
```

**Resposta Esperada (201 Created)**

```json
{
  "id": 30,
  "empreendimentos_id": 7,
  "tipo_area_lazer_id": 2,
  "created_at": "2025-05-26T17:30:00Z",
  "updated_at": "2025-05-26T17:30:00Z"
}
```

### Excluir Área de Lazer

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/areas-lazer/30" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

**Resposta Esperada (200 OK)**

```json
{ "message": "Área de lazer removida com sucesso." }
```

---

## CRUD de Endereço de Empreendimento

### Criar/Atualizar Endereço

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/7/endereco" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "cep": "70000-000",
    "estado": "DF",
    "cidade": "Brasília",
    "bairro": "Plano Piloto",
    "rua": "Eixo Monumental",
    "numero": "1000",
    "complemento": "Bloco B"
  }'
```

**Resposta Esperada (200 OK)**

```json
{
  "id": 7,
  "empreendimentos_id": 7,
  "cep": "70000-000",
  "estado": "DF",
  "cidade": "Brasília",
  "bairro": "Plano Piloto",
  "rua": "Eixo Monumental",
  "numero": "1000",
  "complemento": "Bloco B",
  "created_at": "2025-05-26T18:00:00Z",
  "updated_at": "2025-05-26T18:00:00Z"
}
```

---

## CRUD de Imagens e Arquivos

### Criar Imagem/Arquivo

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos/7/imagens-arquivos" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "foto_url": "https://example.com/fotos/empreendimento7.jpg",
    "arquivo_url": "https://example.com/docs/planta.pdf"
  }'
```

**Resposta Esperada (201 Created)**

```json
{
  "id": 55,
  "empreendimentos_id": 7,
  "foto_url": "https://example.com/fotos/empreendimento7.jpg",
  "arquivo_url": "https://example.com/docs/planta.pdf",
  "created_at": "2025-05-26T18:30:00Z",
  "updated_at": "2025-05-26T18:30:00Z"
}
```

### Excluir Imagem/Arquivo

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/imagens-arquivos/55" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

**Resposta Esperada (200 OK)**

```json
{ "message": "Arquivo removido com sucesso." }
```

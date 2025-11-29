# Testes de Integração - API Negociações

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api`

**Headers Comuns:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

## Listar Negociações

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes?per_page=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "data": [
    {
      "id": 5,
      "empreendimentos_id": 2,
      "empreendimentos_unidades_id": 15,
      "clientes_id": 10,
      "equipe_usuarios_id": 3,
      "corretores_id": null,
      "valor_contrato": 350000.00,
      "numero_contrato": "CONTRATO123",
      "data": "2025-05-20",
      "modalidades_vendas_id": 1,
      "situacoes_vendas_id": 2,
      "validade": "2025-06-20",
      "conformidades_vendas_id": null,
      "nome_correspondente": null,
      "imobiliarias_id": null,
      "ibti_registro_vendas_id": null,
      "valor_entrada_ato": 50000.00,
      "quantidade_parcelas_disponiveis_id": 12,
      "valor_reforco": null,
      "valor_financiamento": 300000.00,
      "nome_banco": "Banco Exemplo",
      "diferenca_valor": 0.00,
      "percentual_comissao": 5.00,
      "equipe_usuarios_id_corretor": null,
      "negociacoes_status_id": 1,
      "empreendimento": { /* objeto empreendimento */ },
      "unidade": { /* objeto unidade */ },
      "cliente": { /* objeto cliente */ },
      "corretor": { /* objeto corretor */ },
      "equipeUsuario": { /* objeto equipeUsuario */ }
    }
  ],
  "links": { /* paginação */ },
  "meta": { /* paginação */ }
}
```

## Obter Negociação por ID

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "id": 5,
  "empreendimentos_id": 2,
  "empreendimentos_unidades_id": 15,
  "clientes_id": 10,
  "equipe_usuarios_id": 3,
  "corretores_id": null,
  "valor_contrato": 350000.00,
  "numero_contrato": "CONTRATO123",
  "data": "2025-05-20",
  "modalidades_vendas_id": 1,
  "situacoes_vendas_id": 2,
  "validade": "2025-06-20",
  "conformidades_vendas_id": null,
  "nome_correspondente": null,
  "imobiliarias_id": null,
  "ibti_registro_vendas_id": null,
  "valor_entrada_ato": 50000.00,
  "quantidade_parcelas_disponiveis_id": 12,
  "valor_reforco": null,
  "valor_financiamento": 300000.00,
  "nome_banco": "Banco Exemplo",
  "diferenca_valor": 0.00,
  "percentual_comissao": 5.00,
  "equipe_usuarios_id_corretor": null,
  "negociacoes_status_id": 1,
  "empreendimento": { /* objeto empreendimento */ },
  "unidade": { /* objeto unidade */ },
  "cliente": { /* objeto cliente */ },
  "corretor": { /* objeto corretor */ },
  "equipeUsuario": { /* objeto equipeUsuario */ }
}
```

## Criar Negociação

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "empreendimentos_id": 2,
    "empreendimentos_unidades_id": 15,
    "clientes_id": 10,
    "equipe_usuarios_id": 3,
    "valor_contrato": 350000.00,
    "numero_contrato": "CONTRATO123",
    "data": "2025-05-20"
  }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 6,
  "empreendimentos_id": 2,
  "empreendimentos_unidades_id": 15,
  "clientes_id": 10,
  "equipe_usuarios_id": 3,
  "corretores_id": null,
  "valor_contrato": 350000.00,
  "numero_contrato": "CONTRATO123",
  "data": "2025-05-20",
  "modalidades_vendas_id": null,
  "situacoes_vendas_id": null,
  "validade": null,
  "conformidades_vendas_id": null,
  "nome_correspondente": null,
  "imobiliarias_id": null,
  "ibti_registro_vendas_id": null,
  "valor_entrada_ato": null,
  "quantidade_parcelas_disponiveis_id": null,
  "valor_reforco": null,
  "valor_financiamento": null,
  "nome_banco": null,
  "diferenca_valor": null,
  "percentual_comissao": null,
  "equipe_usuarios_id_corretor": null,
  "negociacoes_status_id": null,
  "created_at": "2025-05-26T14:00:00Z",
  "updated_at": "2025-05-26T14:00:00Z"
}
```

## Atualizar Negociação

### Requisição

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/6" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "valor_contrato": 360000.00,
    "situacoes_vendas_id": 3
  }'
```

### Resposta Esperada (200 OK)

```json
{
  "id": 6,
  "empreendimentos_id": 2,
  "empreendimentos_unidades_id": 15,
  "clientes_id": 10,
  "equipe_usuarios_id": 3,
  "corretores_id": null,
  "valor_contrato": 360000.00,
  "numero_contrato": "CONTRATO123",
  "data": "2025-05-20",
  "modalidades_vendas_id": null,
  "situacoes_vendas_id": 3,
  "validade": null,
  "conformidades_vendas_id": null,
  "nome_correspondente": null,
  "imobiliarias_id": null,
  "ibti_registro_vendas_id": null,
  "valor_entrada_ato": null,
  "quantidade_parcelas_disponiveis_id": null,
  "valor_reforco": null,
  "valor_financiamento": null,
  "nome_banco": null,
  "diferenca_valor": null,
  "percentual_comissao": null,
  "equipe_usuarios_id_corretor": null,
  "negociacoes_status_id": null,
  "created_at": "2025-05-26T14:00:00Z",
  "updated_at": "2025-05-27T10:00:00Z"
}
```

## Excluir Negociação

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/6" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Negociação removida com sucesso." }
```

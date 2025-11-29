
# 📘 Testes de API - CRUD de Negociações

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api/`

Todos os testes abaixo utilizam token de autenticação e aceitam JSON.

### Headers Comuns

```bash
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## 🔍 Listar Negociações

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes?per_page=10" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## 📌 Visualizar Negociação

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/1" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## ➕ Criar Nova Negociação

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
-H "Content-Type: application/json" \
-d '{
  "empreendimentos_id": 1,
  "empreendimentos_unidades_id": 2,
  "clientes_id": 3,
  "equipe_usuarios_id": 4,
  "corretores_id": 5,
  "valor_contrato": 150000.00,
  "numero_contrato": "NC-2025-001",
  "data": "2025-05-27",
  "modalidades_vendas_id": 1,
  "situacoes_vendas_id": 1,
  "validade": "2025-06-15",
  "conformidades_vendas_id": 2,
  "nome_correspondente": "Correspondente XPTO",
  "imobiliarias_id": 3,
  "valor_entrada_ato": 20000.00,
  "quantidade_parcelas_disponiveis_id": 12,
  "valor_reforco": 10000.00,
  "valor_financiamento": 120000.00,
  "nome_banco": "Banco XPTO",
  "diferenca_valor": 0.00,
  "percentual_comissao": 5.00,
  "equipe_usuarios_id_corretor": 6,
  "negociacoes_status_id": 1,
  "numero_itbi": "ITBI-001-2025",
  "itbi_data_pagamento_protocolo": "2025-05-28",
  "registro_imoveis_data_registro": "2025-05-29",
  "registro_imoveis_cidade_cartorio": "Cartório Central",
  "observacoes": "Negociação com condições especiais.",
  "parcelas_atos_numero": 2,
  "parcelas_construtora_numero": 3,
  "parcelas_construtora_data_pagamento": "2025-06-01",
  "valor_fgts": 5000.00,
  "utilizar_fgts": true,
  "data_vencimento_avaliacao_cca": "2025-06-05",
  "data_assinatura_contrato_construtora": "2025-06-10"
}'
```

---

## ✏️ Atualizar Negociação

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/1" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
-H "Content-Type: application/json" \
-d '{
  "valor_contrato": 155000.00,
  "numero_contrato": "NC-2025-001-ATUALIZADO",
  "nome_banco": "Banco Atualizado",
  "utilizar_fgts": false
}'
```

---

## 🗑️ Deletar Negociação

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes/1" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

> Substitua `SEU_TOKEN_AQUI` pelo token válido de autenticação.

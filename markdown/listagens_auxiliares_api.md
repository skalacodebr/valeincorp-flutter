# Testes de API - Listagens Auxiliares

Base URL: `https://valeincorp-main-s7ucsa.laravel.cloud/api/`

Todas as requisições abaixo utilizam token de autenticação e aceitam JSON.

---

## Headers comuns

```
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Tipo Empreendimentos

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/tipo-empreendimentos" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Tipo Unidades

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/tipo-unidades" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status Unidades

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/status-unidades" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Tipo Áreas de Lazer

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/tipo-areas-lazer" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status Empreendimentos

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/empreendimentos-status" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status Clientes

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/status-clientes" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Modalidades de Venda

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/modalidades-vendas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Situações de Venda

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/situacoes-vendas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Conformidades de Venda

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/conformidades-vendas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Registros IBTI

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/ibti-registro-vendas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Quantidade de Parcelas Disponíveis

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/quantidade-parcelas-disponiveis" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status de Negociações

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/negociacoes-status" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status de Pagamentos de Parcelas

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/status-pagamentos-parcelas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Formas de Pagamento

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/formas-pagamento" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

---

## Listar Status de Leads

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/status-leads" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

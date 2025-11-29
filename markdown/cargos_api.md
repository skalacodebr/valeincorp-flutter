# Testes API - CRUD de Cargos

**Cabeçalho comum para todas as requisições:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
```

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api/`

---

## Listar Cargos
```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/cargos" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## Visualizar Cargo (detalhe)
```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/cargos/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## Criar Novo Cargo
```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/cargos" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Desenvolvedor"
}'
```

## Atualizar Cargo
```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/cargos/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Desenvolvedor Sênior"
}'
```

## Deletar Cargo
```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/cargos/1" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

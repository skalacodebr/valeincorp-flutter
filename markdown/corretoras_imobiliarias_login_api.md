# Login API - Corretoras e Corretores

Este documento descreve os endpoints de autenticação para **corretores** e **corretoras** (imobiliárias), usando JWT.

Base URL:  
```
https://valeincorp-main-s7ucsa.laravel.cloud/api/
```

Cabeçalhos comuns em todas as requisições:
```
-H "Accept: application/json" -H "Content-Type: application/json" ```

---

## 1. Login de Corretores

### Endpoint
```
POST /login/corretor
```

### Descrição
Autentica um corretor e retorna um token JWT para acesso às rotas protegidas.

### Request
```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/login/corretor"   -H "Accept: application/json"   -H "Content-Type: application/json"   -d '{
    "email": "corretor@example.com",
    "senha": "senhaSegura123"
}'
```

### Resposta de Sucesso (200)
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "nome": "João Silva",
    "email": "corretor@example.com"
  }
}
```

### Erros Comuns
- **401 Unauthorized**: credenciais inválidas.
- **422 Unprocessable Entity**: validação de campos (ex.: email ausente).

---

## 2. Login de Corretoras (Imobiliárias)

### Endpoint
```
POST /login/corretora
```

### Descrição
Autentica uma corretora (imobiliária) e retorna um token JWT para acesso às rotas protegidas.

### Request
```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/login/corretora"   -H "Accept: application/json"   -H "Content-Type: application/json"   -d '{
    "email": "contato@imobiliaria.com",
    "senha": "senhaSuperSegura456"
}'
```

### Resposta de Sucesso (200)
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "nome": "Imobiliária ABC",
    "email": "contato@imobiliaria.com"
  }
}
```

### Erros Comuns
- **401 Unauthorized**: credenciais inválidas.
- **422 Unprocessable Entity**: validação de campos (ex.: senha ausente).

---

## 3. Rotas Adicionais (Opcional)

- **POST /logout**  
  Encerra a sessão (revoga o token).

- **POST /refresh**  
  Renova o token JWT.

- **GET /me**  
  Retorna dados do usuário autenticado.


# API de Recuperação de Senha - Documentação Completa

## Visão Geral
Sistema completo de recuperação de senha com token de 6 dígitos enviado por email.

## Endpoints

### 1. Solicitar Token de Recuperação
**Endpoint:** `POST /api/corretores/recuperar-senha`

Envia um token de 6 dígitos para o email do corretor cadastrado.

#### Request
```json
{
    "email": "corretor@exemplo.com"
}
```

#### Response - Sucesso (200)
```json
{
    "message": "Token enviado para o e-mail informado."
}
```

#### Response - Email não encontrado (404)
```json
{
    "message": "E-mail não encontrado.",
    "code": "EMAIL_NOT_FOUND"
}
```

#### Response - Erro ao enviar email (500)
```json
{
    "message": "Falha ao enviar o e-mail. Tente novamente em instantes.",
    "code": "MAIL_SEND_FAILED"
}
```

#### Exemplo CURL
```bash
curl -X POST https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/recuperar-senha \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "corretor@exemplo.com"
  }'
```

### 2. Redefinir Senha com Token
**Endpoint:** `POST /api/corretores/redefinir-senha`

Redefine a senha usando o token recebido por email.

#### Request
```json
{
    "email": "corretor@exemplo.com",
    "token": "123456",
    "password": "novaSenha123",
    "password_confirmation": "novaSenha123"
}
```

#### Response - Sucesso (200)
```json
{
    "message": "Senha redefinida com sucesso."
}
```

#### Response - Email não encontrado (404)
```json
{
    "message": "E-mail não encontrado.",
    "code": "EMAIL_NOT_FOUND"
}
```

#### Response - Token inválido (401)
```json
{
    "message": "Token inválido.",
    "code": "INVALID_TOKEN"
}
```

#### Response - Erro de validação (422)
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "password": [
            "The password field must be at least 6 characters."
        ],
        "password_confirmation": [
            "The password confirmation does not match."
        ]
    }
}
```

#### Exemplo CURL
```bash
curl -X POST https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/redefinir-senha \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "corretor@exemplo.com",
    "token": "123456",
    "password": "novaSenha123",
    "password_confirmation": "novaSenha123"
  }'
```

## Integração Front-end

### JavaScript/Fetch API

#### 1. Solicitar Token
```javascript
async function solicitarTokenRecuperacao(email) {
    try {
        const response = await fetch('https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/recuperar-senha', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ email })
        });

        const data = await response.json();
        
        if (response.ok) {
            console.log('Token enviado com sucesso');
            return { success: true, message: data.message };
        } else {
            console.error('Erro:', data.message);
            return { success: false, message: data.message, code: data.code };
        }
    } catch (error) {
        console.error('Erro na requisição:', error);
        return { success: false, message: 'Erro de conexão' };
    }
}

// Uso
solicitarTokenRecuperacao('corretor@exemplo.com')
    .then(result => {
        if (result.success) {
            alert('Token enviado! Verifique seu email.');
            // Redirecionar para tela de inserir token
        } else {
            alert('Erro: ' + result.message);
        }
    });
```

#### 2. Redefinir Senha
```javascript
async function redefinirSenha(email, token, password, passwordConfirmation) {
    try {
        const response = await fetch('https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/redefinir-senha', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                email,
                token,
                password,
                password_confirmation: passwordConfirmation
            })
        });

        const data = await response.json();
        
        if (response.ok) {
            console.log('Senha redefinida com sucesso');
            return { success: true, message: data.message };
        } else {
            console.error('Erro:', data);
            return { 
                success: false, 
                message: data.message, 
                code: data.code,
                errors: data.errors 
            };
        }
    } catch (error) {
        console.error('Erro na requisição:', error);
        return { success: false, message: 'Erro de conexão' };
    }
}

// Uso
redefinirSenha(
    'corretor@exemplo.com',
    '123456',
    'novaSenha123',
    'novaSenha123'
).then(result => {
    if (result.success) {
        alert('Senha redefinida com sucesso!');
        // Redirecionar para login
    } else {
        if (result.errors) {
            // Mostrar erros de validação
            Object.keys(result.errors).forEach(field => {
                console.error(`${field}: ${result.errors[field].join(', ')}`);
            });
        } else {
            alert('Erro: ' + result.message);
        }
    }
});
```

### React Example

```jsx
import React, { useState } from 'react';

function RecuperacaoSenha() {
    const [step, setStep] = useState(1); // 1: email, 2: token e nova senha
    const [email, setEmail] = useState('');
    const [token, setToken] = useState('');
    const [password, setPassword] = useState('');
    const [passwordConfirmation, setPasswordConfirmation] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleRequestToken = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const response = await fetch('https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/recuperar-senha', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ email })
            });

            const data = await response.json();

            if (response.ok) {
                setStep(2);
                alert('Token enviado! Verifique seu email.');
            } else {
                setError(data.message);
            }
        } catch (err) {
            setError('Erro de conexão');
        } finally {
            setLoading(false);
        }
    };

    const handleResetPassword = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const response = await fetch('https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/redefinir-senha', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    email,
                    token,
                    password,
                    password_confirmation: passwordConfirmation
                })
            });

            const data = await response.json();

            if (response.ok) {
                alert('Senha redefinida com sucesso!');
                // Redirecionar para login
            } else {
                setError(data.message);
            }
        } catch (err) {
            setError('Erro de conexão');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            {step === 1 ? (
                <form onSubmit={handleRequestToken}>
                    <h2>Recuperar Senha</h2>
                    <input
                        type="email"
                        placeholder="Digite seu email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                    {error && <p style={{color: 'red'}}>{error}</p>}
                    <button type="submit" disabled={loading}>
                        {loading ? 'Enviando...' : 'Enviar Token'}
                    </button>
                </form>
            ) : (
                <form onSubmit={handleResetPassword}>
                    <h2>Redefinir Senha</h2>
                    <input
                        type="text"
                        placeholder="Token de 6 dígitos"
                        value={token}
                        onChange={(e) => setToken(e.target.value)}
                        maxLength="6"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Nova senha"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        minLength="6"
                        required
                    />
                    <input
                        type="password"
                        placeholder="Confirmar nova senha"
                        value={passwordConfirmation}
                        onChange={(e) => setPasswordConfirmation(e.target.value)}
                        minLength="6"
                        required
                    />
                    {error && <p style={{color: 'red'}}>{error}</p>}
                    <button type="submit" disabled={loading}>
                        {loading ? 'Redefinindo...' : 'Redefinir Senha'}
                    </button>
                </form>
            )}
        </div>
    );
}

export default RecuperacaoSenha;
```

## Fluxo Completo

1. **Usuário solicita recuperação**
   - Insere email no formulário
   - Sistema verifica se email existe na tabela `corretores`
   - Gera token de 6 dígitos
   - Salva token na coluna `token` da tabela `corretores`
   - Envia email com o token

2. **Usuário recebe email**
   - Email contém token de 6 dígitos
   - Email tem layout profissional com instruções

3. **Usuário redefine senha**
   - Insere email, token e nova senha
   - Sistema valida token
   - Atualiza senha (com hash)
   - Limpa token do banco
   - Retorna sucesso

## Configurações SMTP

As configurações de email já estão configuradas no arquivo `.env`:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=suporte.valeincorp@gmail.com
MAIL_PASSWORD="panr zjcs yoqj fcse"
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=suporte.valeincorp@gmail.com
MAIL_FROM_NAME="Valeincorp"
```

## Testes

### Teste com cURL - Fluxo Completo

```bash
# 1. Solicitar token
curl -X POST https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/recuperar-senha \
  -H "Content-Type: application/json" \
  -d '{"email": "corretor@exemplo.com"}'

# 2. Aguardar receber o token por email

# 3. Redefinir senha com o token recebido
curl -X POST https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api/corretores/redefinir-senha \
  -H "Content-Type: application/json" \
  -d '{
    "email": "corretor@exemplo.com",
    "token": "123456",
    "password": "novaSenha123",
    "password_confirmation": "novaSenha123"
  }'
```

## Observações Importantes

1. **Segurança do Token**
   - Token é numérico de 6 dígitos
   - Token é único por corretor
   - Token é limpo após uso bem-sucedido
   - Recomenda-se adicionar expiração de token (não implementado ainda)

2. **Validações**
   - Email deve existir na tabela `corretores`
   - Token deve corresponder ao salvo no banco
   - Senha mínima de 6 caracteres
   - Confirmação de senha deve coincidir

3. **Hash de Senha**
   - Senhas são armazenadas com hash usando bcrypt
   - Nunca armazene senhas em texto plano

4. **Template de Email**
   - Template responsivo e profissional
   - Instruções claras para o usuário
   - Alerta de segurança incluído
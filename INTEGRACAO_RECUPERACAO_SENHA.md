# Integração API - Recuperação de Senha

**URL Base da API:** `https://backend.valeincorp.com.br/api/`

## Endpoints Disponíveis

### 1. Solicitar Token de Recuperação
**URL:** `https://backend.valeincorp.com.br/api/corretores/recuperar-senha`  
**Método:** `POST`

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

#### Response - Erro Email não encontrado (404)
```json
{
    "message": "E-mail não encontrado.",
    "code": "EMAIL_NOT_FOUND"
}
```

#### Response - Erro no envio (500)
```json
{
    "message": "Falha ao enviar o e-mail. Tente novamente em instantes.",
    "code": "MAIL_SEND_FAILED"
}
```

---

### 2. Redefinir Senha com Token
**URL:** `https://backend.valeincorp.com.br/api/corretores/redefinir-senha`  
**Método:** `POST`

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
        "email": ["O campo email é obrigatório."],
        "token": ["O campo token deve ter exatamente 6 dígitos."],
        "password": ["O campo password deve ter pelo menos 6 caracteres."],
        "password_confirmation": ["A confirmação da senha não confere."]
    }
}
```

---

## Integração Front-end

### JavaScript Puro / Fetch API

#### 1. Solicitar Token de Recuperação
```javascript
async function solicitarToken(email) {
    try {
        const response = await fetch('https://backend.valeincorp.com.br/api/corretores/recuperar-senha', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ email })
        });

        const data = await response.json();
        
        if (response.ok) {
            return { 
                success: true, 
                message: data.message 
            };
        } else {
            return { 
                success: false, 
                message: data.message,
                code: data.code,
                status: response.status
            };
        }
    } catch (error) {
        return { 
            success: false, 
            message: 'Erro de conexão. Verifique sua internet.',
            error: error.message
        };
    }
}

// Exemplo de uso
solicitarToken('corretor@exemplo.com')
    .then(result => {
        if (result.success) {
            alert('✅ ' + result.message);
            // Redirecionar para tela de inserir token
        } else {
            alert('❌ ' + result.message);
        }
    });
```

#### 2. Redefinir Senha com Token
```javascript
async function redefinirSenha(email, token, password, passwordConfirmation) {
    try {
        const response = await fetch('https://backend.valeincorp.com.br/api/corretores/redefinir-senha', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                email: email,
                token: token,
                password: password,
                password_confirmation: passwordConfirmation
            })
        });

        const data = await response.json();
        
        if (response.ok) {
            return { 
                success: true, 
                message: data.message 
            };
        } else {
            return { 
                success: false, 
                message: data.message,
                code: data.code,
                errors: data.errors || null,
                status: response.status
            };
        }
    } catch (error) {
        return { 
            success: false, 
            message: 'Erro de conexão. Verifique sua internet.',
            error: error.message
        };
    }
}

// Exemplo de uso
redefinirSenha('corretor@exemplo.com', '123456', 'novaSenha123', 'novaSenha123')
    .then(result => {
        if (result.success) {
            alert('✅ ' + result.message);
            // Redirecionar para login
            window.location.href = '/login';
        } else {
            if (result.errors) {
                // Mostrar erros de validação específicos
                let errorMessage = 'Erros encontrados:\n';
                Object.keys(result.errors).forEach(field => {
                    errorMessage += `• ${result.errors[field].join(', ')}\n`;
                });
                alert(errorMessage);
            } else {
                alert('❌ ' + result.message);
            }
        }
    });
```

---

### React/Next.js

#### Hook personalizado para recuperação de senha
```jsx
import { useState } from 'react';

const usePasswordRecovery = () => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const solicitarToken = async (email) => {
        setLoading(true);
        setError('');
        
        try {
            const response = await fetch('https://backend.valeincorp.com.br/api/corretores/recuperar-senha', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ email })
            });

            const data = await response.json();

            if (response.ok) {
                return { success: true, message: data.message };
            } else {
                setError(data.message);
                return { success: false, message: data.message, code: data.code };
            }
        } catch (err) {
            const errorMsg = 'Erro de conexão. Verifique sua internet.';
            setError(errorMsg);
            return { success: false, message: errorMsg };
        } finally {
            setLoading(false);
        }
    };

    const redefinirSenha = async (email, token, password, passwordConfirmation) => {
        setLoading(true);
        setError('');
        
        try {
            const response = await fetch('https://backend.valeincorp.com.br/api/corretores/redefinir-senha', {
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
                return { success: true, message: data.message };
            } else {
                setError(data.message);
                return { 
                    success: false, 
                    message: data.message,
                    code: data.code,
                    errors: data.errors
                };
            }
        } catch (err) {
            const errorMsg = 'Erro de conexão. Verifique sua internet.';
            setError(errorMsg);
            return { success: false, message: errorMsg };
        } finally {
            setLoading(false);
        }
    };

    return { solicitarToken, redefinirSenha, loading, error, setError };
};

export default usePasswordRecovery;
```

#### Componente de Recuperação de Senha
```jsx
import React, { useState } from 'react';
import usePasswordRecovery from './usePasswordRecovery';

const RecuperacaoSenha = () => {
    const [step, setStep] = useState(1); // 1: email, 2: token e nova senha
    const [email, setEmail] = useState('');
    const [token, setToken] = useState('');
    const [password, setPassword] = useState('');
    const [passwordConfirmation, setPasswordConfirmation] = useState('');
    
    const { solicitarToken, redefinirSenha, loading, error, setError } = usePasswordRecovery();

    const handleSolicitarToken = async (e) => {
        e.preventDefault();
        
        const result = await solicitarToken(email);
        if (result.success) {
            setStep(2);
            alert('Token enviado! Verifique seu email.');
        }
    };

    const handleRedefinirSenha = async (e) => {
        e.preventDefault();
        
        if (password !== passwordConfirmation) {
            setError('As senhas não coincidem');
            return;
        }
        
        const result = await redefinirSenha(email, token, password, passwordConfirmation);
        if (result.success) {
            alert('Senha redefinida com sucesso!');
            // Redirecionar para login ou fazer outra ação
        }
    };

    return (
        <div style={{ maxWidth: '400px', margin: '50px auto', padding: '20px' }}>
            {step === 1 ? (
                <form onSubmit={handleSolicitarToken}>
                    <h2>Recuperar Senha</h2>
                    <div style={{ marginBottom: '15px' }}>
                        <label>Email:</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Digite seu email"
                            required
                            style={{
                                width: '100%',
                                padding: '10px',
                                marginTop: '5px',
                                border: '1px solid #ddd',
                                borderRadius: '4px'
                            }}
                        />
                    </div>
                    
                    {error && (
                        <div style={{ color: 'red', marginBottom: '15px' }}>
                            {error}
                        </div>
                    )}
                    
                    <button
                        type="submit"
                        disabled={loading}
                        style={{
                            width: '100%',
                            padding: '12px',
                            backgroundColor: loading ? '#ccc' : '#007bff',
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px',
                            cursor: loading ? 'not-allowed' : 'pointer'
                        }}
                    >
                        {loading ? 'Enviando...' : 'Enviar Token'}
                    </button>
                </form>
            ) : (
                <form onSubmit={handleRedefinirSenha}>
                    <h2>Redefinir Senha</h2>
                    
                    <div style={{ marginBottom: '15px' }}>
                        <label>Token (6 dígitos):</label>
                        <input
                            type="text"
                            value={token}
                            onChange={(e) => setToken(e.target.value)}
                            placeholder="000000"
                            maxLength="6"
                            pattern="[0-9]{6}"
                            required
                            style={{
                                width: '100%',
                                padding: '10px',
                                marginTop: '5px',
                                border: '1px solid #ddd',
                                borderRadius: '4px',
                                textAlign: 'center',
                                fontSize: '18px',
                                letterSpacing: '2px'
                            }}
                        />
                    </div>
                    
                    <div style={{ marginBottom: '15px' }}>
                        <label>Nova Senha:</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Mínimo 6 caracteres"
                            minLength="6"
                            required
                            style={{
                                width: '100%',
                                padding: '10px',
                                marginTop: '5px',
                                border: '1px solid #ddd',
                                borderRadius: '4px'
                            }}
                        />
                    </div>
                    
                    <div style={{ marginBottom: '15px' }}>
                        <label>Confirmar Nova Senha:</label>
                        <input
                            type="password"
                            value={passwordConfirmation}
                            onChange={(e) => setPasswordConfirmation(e.target.value)}
                            placeholder="Digite a senha novamente"
                            minLength="6"
                            required
                            style={{
                                width: '100%',
                                padding: '10px',
                                marginTop: '5px',
                                border: '1px solid #ddd',
                                borderRadius: '4px'
                            }}
                        />
                    </div>
                    
                    {error && (
                        <div style={{ color: 'red', marginBottom: '15px' }}>
                            {error}
                        </div>
                    )}
                    
                    <button
                        type="submit"
                        disabled={loading}
                        style={{
                            width: '100%',
                            padding: '12px',
                            backgroundColor: loading ? '#ccc' : '#28a745',
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px',
                            cursor: loading ? 'not-allowed' : 'pointer'
                        }}
                    >
                        {loading ? 'Redefinindo...' : 'Redefinir Senha'}
                    </button>
                    
                    <button
                        type="button"
                        onClick={() => setStep(1)}
                        style={{
                            width: '100%',
                            padding: '10px',
                            backgroundColor: 'transparent',
                            color: '#007bff',
                            border: '1px solid #007bff',
                            borderRadius: '4px',
                            cursor: 'pointer',
                            marginTop: '10px'
                        }}
                    >
                        ← Voltar
                    </button>
                </form>
            )}
        </div>
    );
};

export default RecuperacaoSenha;
```

---

### Vue.js

#### Composable para Vue 3
```javascript
// composables/usePasswordRecovery.js
import { ref } from 'vue'

export const usePasswordRecovery = () => {
    const loading = ref(false)
    const error = ref('')

    const solicitarToken = async (email) => {
        loading.value = true
        error.value = ''
        
        try {
            const response = await fetch('https://backend.valeincorp.com.br/api/corretores/recuperar-senha', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ email })
            })

            const data = await response.json()

            if (response.ok) {
                return { success: true, message: data.message }
            } else {
                error.value = data.message
                return { success: false, message: data.message, code: data.code }
            }
        } catch (err) {
            const errorMsg = 'Erro de conexão. Verifique sua internet.'
            error.value = errorMsg
            return { success: false, message: errorMsg }
        } finally {
            loading.value = false
        }
    }

    const redefinirSenha = async (email, token, password, passwordConfirmation) => {
        loading.value = true
        error.value = ''
        
        try {
            const response = await fetch('https://backend.valeincorp.com.br/api/corretores/redefinir-senha', {
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
            })

            const data = await response.json()

            if (response.ok) {
                return { success: true, message: data.message }
            } else {
                error.value = data.message
                return { 
                    success: false, 
                    message: data.message,
                    code: data.code,
                    errors: data.errors
                }
            }
        } catch (err) {
            const errorMsg = 'Erro de conexão. Verifique sua internet.'
            error.value = errorMsg
            return { success: false, message: errorMsg }
        } finally {
            loading.value = false
        }
    }

    return { solicitarToken, redefinirSenha, loading, error }
}
```

---

## Testes com cURL

### 1. Testar Solicitação de Token
```bash
curl -X POST "https://backend.valeincorp.com.br/api/corretores/recuperar-senha" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email": "seu-email@exemplo.com"}' \
  -w "\n\nStatus HTTP: %{http_code}\n"
```

### 2. Testar Redefinição de Senha
```bash
curl -X POST "https://backend.valeincorp.com.br/api/corretores/redefinir-senha" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "seu-email@exemplo.com",
    "token": "123456",
    "password": "novaSenha123",
    "password_confirmation": "novaSenha123"
  }' \
  -w "\n\nStatus HTTP: %{http_code}\n"
```

---

## Validações e Regras

### Validações do Campo Email
- ✅ Obrigatório
- ✅ Formato de email válido
- ✅ Deve existir na tabela `corretores`

### Validações do Campo Token
- ✅ Obrigatório
- ✅ Exatamente 6 dígitos numéricos
- ✅ Deve coincidir com o token salvo no banco

### Validações do Campo Password
- ✅ Obrigatório
- ✅ Mínimo 6 caracteres
- ✅ Deve ter confirmação igual

### Validações do Campo password_confirmation
- ✅ Obrigatório
- ✅ Deve ser igual ao campo `password`

---

## Fluxo de Uso Recomendado

### 1. Tela de Recuperação - Passo 1 (Email)
```html
<form id="form-email">
    <h2>Recuperar Senha</h2>
    <p>Digite seu email para receber o código de recuperação:</p>
    
    <input type="email" id="email" placeholder="seu-email@exemplo.com" required>
    <button type="submit">Enviar Código</button>
</form>
```

### 2. Tela de Recuperação - Passo 2 (Token + Nova Senha)
```html
<form id="form-reset">
    <h2>Redefinir Senha</h2>
    <p>Digite o código de 6 dígitos enviado para seu email:</p>
    
    <input type="text" id="token" placeholder="000000" maxlength="6" required>
    <input type="password" id="password" placeholder="Nova senha (mín. 6 caracteres)" required>
    <input type="password" id="password_confirmation" placeholder="Confirme a nova senha" required>
    
    <button type="submit">Redefinir Senha</button>
    <button type="button" onclick="voltarParaEmail()">← Voltar</button>
</form>
```

### 3. Tratamento de Erros Recomendado
```javascript
// Função para mostrar erros de forma amigável
function mostrarErro(result) {
    switch(result.code) {
        case 'EMAIL_NOT_FOUND':
            alert('Email não cadastrado no sistema.');
            break;
        case 'INVALID_TOKEN':
            alert('Código inválido. Verifique se digitou corretamente.');
            break;
        case 'MAIL_SEND_FAILED':
            alert('Erro no envio do email. Tente novamente em alguns minutos.');
            break;
        default:
            alert(result.message || 'Erro desconhecido');
    }
}
```

---

## Considerações de Segurança

### ✅ Implementado
- Token numérico de 6 dígitos
- Hash bcrypt para senhas
- Validação de email existente
- Limpeza do token após uso

### 🔄 Recomendações Futuras
- Expiração de token (ex: 15 minutos)
- Rate limiting (limitar tentativas)
- Log de tentativas de recuperação
- Captcha para evitar spam

---

## Troubleshooting

### Problema: Email não chega
- Verificar pasta de spam
- Aguardar até 5 minutos
- Verificar se o email está correto

### Problema: Token inválido
- Verificar se digitou corretamente
- Token pode ter expirado
- Solicitar novo token

### Problema: Erro 500
- Verificar conexão com internet
- Aguardar alguns minutos e tentar novamente
- Contatar suporte se persistir
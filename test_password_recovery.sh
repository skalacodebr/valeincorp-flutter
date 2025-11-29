#!/bin/bash

# Script de teste para API de recuperação de senha
# Uso: ./test_password_recovery.sh

BASE_URL="https://crm.valeincorp.com.br/valeincorp/valeincorp-backend/api"
EMAIL="corretor@exemplo.com"

echo "========================================="
echo "Teste de API de Recuperação de Senha"
echo "========================================="
echo ""

# Função para solicitar token
request_token() {
    echo "1. Solicitando token de recuperação para: $EMAIL"
    echo "----------------------------------------"
    
    response=$(curl -s -X POST "$BASE_URL/corretores/recuperar-senha" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"email\": \"$EMAIL\"}")
    
    echo "Response: $response"
    echo ""
}

# Função para redefinir senha
reset_password() {
    echo "2. Redefinindo senha"
    echo "----------------------------------------"
    echo -n "Digite o token de 6 dígitos recebido por email: "
    read TOKEN
    
    echo -n "Digite a nova senha (mínimo 6 caracteres): "
    read -s PASSWORD
    echo ""
    
    echo -n "Confirme a nova senha: "
    read -s PASSWORD_CONFIRM
    echo ""
    
    response=$(curl -s -X POST "$BASE_URL/corretores/redefinir-senha" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{
            \"email\": \"$EMAIL\",
            \"token\": \"$TOKEN\",
            \"password\": \"$PASSWORD\",
            \"password_confirmation\": \"$PASSWORD_CONFIRM\"
        }")
    
    echo "Response: $response"
    echo ""
}

# Menu principal
while true; do
    echo "Escolha uma opção:"
    echo "1. Solicitar token de recuperação"
    echo "2. Redefinir senha com token"
    echo "3. Teste completo (solicitar token e redefinir)"
    echo "4. Sair"
    echo -n "Opção: "
    read option
    echo ""
    
    case $option in
        1)
            request_token
            ;;
        2)
            reset_password
            ;;
        3)
            request_token
            echo "Verifique seu email e quando receber o token..."
            reset_password
            ;;
        4)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida!"
            ;;
    esac
    
    echo "========================================="
    echo ""
done
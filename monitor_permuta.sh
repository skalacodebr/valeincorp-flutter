#!/bin/bash

# Script para monitorar logs de permuta
# Uso: ./monitor_permuta.sh

echo "================================================"
echo "    MONITOR DE LOGS - CAMPO PERMUTA"
echo "================================================"
echo ""
echo "Monitorando logs em tempo real..."
echo "Pressione Ctrl+C para sair"
echo ""
echo "Legenda:"
echo "  ✅ = Sucesso"
echo "  ❌ = Erro"
echo "  🔄 = Alteração"
echo "  📊 = Resumo"
echo ""
echo "================================================"
echo ""

# Cores para o terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Monitorar o log
tail -f storage/logs/laravel.log | while read line; do
    # Destacar linhas importantes
    if echo "$line" | grep -q "❌\|ERROR\|PROBLEMA"; then
        echo -e "${RED}$line${NC}"
    elif echo "$line" | grep -q "✅\|SUCESSO"; then
        echo -e "${GREEN}$line${NC}"
    elif echo "$line" | grep -q "⚠️\|WARNING\|ATENÇÃO"; then
        echo -e "${YELLOW}$line${NC}"
    elif echo "$line" | grep -q "===\|📊\|🔄"; then
        echo -e "${BLUE}$line${NC}"
    elif echo "$line" | grep -q "PERMUTA\|permuta"; then
        echo "$line"
    fi
done
#!/bin/bash
# Script para iniciar o servidor Laravel localmente acessível do iPhone

echo "🚀 Iniciando servidor Laravel..."
echo "📱 Acesse do iPhone usando: http://192.168.2.116:8000"
echo ""
echo "Pressione Ctrl+C para parar o servidor"
echo ""

php artisan serve --host=0.0.0.0 --port=8000

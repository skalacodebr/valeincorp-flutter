#!/bin/bash

# Configuração da API
API_URL="http://localhost/api"
TORRE_ID="1"  # Substitua pelo ID da torre real
TOKEN="SEU_TOKEN_AQUI"  # Substitua pelo token de autenticação

echo "========================================="
echo "TESTES DA API DE VÍDEOS DE UNIDADES"
echo "========================================="

# 1. CRIAR VÍDEO - YouTube
echo -e "\n1. CRIANDO VÍDEO (YouTube):"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "videos_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "categoria": "Tour Virtual"
  }' | json_pp

# 2. CRIAR VÍDEO - Vimeo
echo -e "\n2. CRIANDO VÍDEO (Vimeo):"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "videos_url": "https://vimeo.com/123456789",
    "categoria": "Apresentação"
  }' | json_pp

# 3. LISTAR TODOS OS VÍDEOS
echo -e "\n3. LISTANDO TODOS OS VÍDEOS DA TORRE:"
curl -X GET "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

# 4. BUSCAR VÍDEOS POR CATEGORIA
echo -e "\n4. BUSCANDO VÍDEOS POR CATEGORIA (Tour Virtual):"
curl -X GET "${API_URL}/torres/${TORRE_ID}/videos-unidade/categoria/Tour%20Virtual" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

# 5. LISTAR CATEGORIAS DISPONÍVEIS
echo -e "\n5. LISTANDO CATEGORIAS DISPONÍVEIS:"
curl -X GET "${API_URL}/torres/${TORRE_ID}/videos-categorias" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

# 6. ATUALIZAR VÍDEO (substitua VIDEO_ID pelo ID real)
VIDEO_ID="1"
echo -e "\n6. ATUALIZANDO VÍDEO ID ${VIDEO_ID}:"
curl -X PUT "${API_URL}/torres/${TORRE_ID}/videos-unidade/${VIDEO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "categoria": "Áreas Comuns"
  }' | json_pp

# 7. TESTE COM URL INVÁLIDA (deve retornar erro)
echo -e "\n7. TESTE COM URL INVÁLIDA (deve retornar erro):"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "videos_url": "https://exemplo.com/video.mp4",
    "categoria": "Teste"
  }' | json_pp

# 8. DELETAR VÍDEO (substitua VIDEO_ID pelo ID real)
echo -e "\n8. DELETANDO VÍDEO ID ${VIDEO_ID}:"
curl -X DELETE "${API_URL}/torres/${TORRE_ID}/videos-unidade/${VIDEO_ID}" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

echo -e "\n========================================="
echo "TESTES CONCLUÍDOS"
echo "========================================="
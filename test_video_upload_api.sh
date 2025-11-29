#!/bin/bash

# Configuração da API
API_URL="http://localhost/api"
TORRE_ID="1"  # Substitua pelo ID da torre real
TOKEN="SEU_TOKEN_AQUI"  # Substitua pelo token de autenticação

echo "========================================="
echo "TESTES DA API DE VÍDEOS DE UNIDADES - COM UPLOAD"
echo "========================================="

# 1. CRIAR VÍDEO COM UPLOAD DE ARQUIVO
echo -e "\n1. CRIANDO VÍDEO COM UPLOAD DE ARQUIVO:"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "video_file=@/caminho/para/seu/video.mp4" \
  -F "categoria=Tour Virtual" | json_pp

# 2. CRIAR VÍDEO COM URL EXTERNA (YouTube/Vimeo) - ainda funciona
echo -e "\n2. CRIANDO VÍDEO COM URL EXTERNA (YouTube):"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "videos_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "categoria": "Apresentação"
  }' | json_pp

# 3. LISTAR TODOS OS VÍDEOS
echo -e "\n3. LISTANDO TODOS OS VÍDEOS DA TORRE:"
curl -X GET "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

# 4. ATUALIZAR VÍDEO - SUBSTITUIR POR UPLOAD
VIDEO_ID="1"
echo -e "\n4. ATUALIZANDO VÍDEO ID ${VIDEO_ID} - SUBSTITUINDO POR UPLOAD:"
curl -X PUT "${API_URL}/torres/${TORRE_ID}/videos-unidade/${VIDEO_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "video_file=@/caminho/para/outro/video.mp4" \
  -F "categoria=Áreas Comuns" | json_pp

# 5. ATUALIZAR VÍDEO - APENAS CATEGORIA
echo -e "\n5. ATUALIZANDO VÍDEO ID ${VIDEO_ID} - APENAS CATEGORIA:"
curl -X PUT "${API_URL}/torres/${TORRE_ID}/videos-unidade/${VIDEO_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "categoria": "Nova Categoria"
  }' | json_pp

# 6. TESTE COM ARQUIVO INVÁLIDO (deve retornar erro)
echo -e "\n6. TESTE COM ARQUIVO INVÁLIDO (deve retornar erro):"
curl -X POST "${API_URL}/torres/${TORRE_ID}/videos-unidade" \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "video_file=@/caminho/para/arquivo.txt" \
  -F "categoria=Teste" | json_pp

# 7. DELETAR VÍDEO (remove arquivo do storage)
echo -e "\n7. DELETANDO VÍDEO ID ${VIDEO_ID}:"
curl -X DELETE "${API_URL}/torres/${TORRE_ID}/videos-unidade/${VIDEO_ID}" \
  -H "Authorization: Bearer ${TOKEN}" | json_pp

echo -e "\n========================================="
echo "TESTES CONCLUÍDOS"
echo "========================================="

echo -e "\nNOTAS IMPORTANTES:"
echo "- Substitua '/caminho/para/seu/video.mp4' pelo caminho real do arquivo"
echo "- Formatos suportados: MP4, MPEG, QuickTime, AVI, WebM"
echo "- Tamanho máximo: 100MB (102400KB)"
echo "- Ainda aceita URLs do YouTube/Vimeo como alternativa"
echo "- Agora salva arquivos no storage: /storage/videos/unidades/"
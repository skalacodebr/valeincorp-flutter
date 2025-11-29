# 🏢 API de Imóveis com Estatísticas de Unidades

## 🎯 **Implementação Realizada**

Implementei na API de imóveis as estatísticas das unidades, incluindo porcentagem de vendas, total de unidades, disponíveis, etc.

## 📋 **Alterações Feitas:**

### **1. Model Empreendimento.php:**
- ✅ Adicionado relacionamento `unidades()` 
- ✅ Adicionado accessor `getStatisticsAttribute()`
- ✅ Cálculo automático de estatísticas baseado no `status_unidades_id`

### **2. ImovelController.php:**
- ✅ Incluído `'unidades'` nos relacionamentos carregados
- ✅ Atualizado `formatImovelBasic()` para incluir estatísticas
- ✅ Adicionados métodos `getStatusEmpreendimentoFromStats()` e `getStatusVenda()`

## 📊 **Estatísticas Calculadas:**

| Campo | Descrição | Cálculo |
|-------|-----------|---------|
| `totalUnidades` | Total de unidades do empreendimento | COUNT(*) |
| `unidadesVendidas` | Unidades com status "Vendida" (ID=3) | COUNT WHERE status_unidades_id = 3 |
| `percentualVendido` | Porcentagem de vendas | (vendidas / total) * 100 |
| `unidadesDisponiveis` | Unidades disponíveis (ID=1) | COUNT WHERE status_unidades_id = 1 |
| `valorMedio` | Preço médio das unidades | AVG(valor) |

## 🔗 **Endpoint:**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/imoveis?page=1&limit=20"
```

## ✅ **Resposta Esperada (com unidades cadastradas):**

```json
{
    "success": true,
    "data": [
        {
            "id": 2,
            "codigo": "VIC002",
            "nome": "CITTÀ SIENA RESIDENCIAL",
            "imagem": "https://backend.valeincorp.com.br/storage/unidades/foto_xyz.jpg",
            "localizacao": "Rondônia - Novo Hamburgo",
            "data": "2025-07-18",
            "corretor": "Vale Incorp",
            "cidade": "Novo Hamburgo",
            "status": "Em Comercialização",
            "preco": 850000.00,
            "precoFormatado": "R$ 850.000,00",
            "dormitorios": 3,
            "banheiros": 2,
            "suites": 1,
            "vagas": 2,
            "area": 120,
            
            // 🆕 NOVOS CAMPOS - ESTATÍSTICAS DAS UNIDADES
            "unidadesDisponiveis": 18,
            "totalUnidades": 48,
            "unidadesVendidas": 30,
            "percentualVendido": 62.5,
            "statusVenda": "vendendo_bem",
            
            "valorM2": 1904.76,
            "coordenadas": {
                "latitude": -23.5505,
                "longitude": -46.6333
            },
            "createdAt": "2025-07-18T13:46:00.000000Z",
            "updatedAt": "2025-07-24T14:25:36.000000Z"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 6,
        "itemsPerPage": 20,
        "hasNextPage": false,
        "hasPreviousPage": false
    }
}
```

## 🎨 **Status Dinâmicos:**

### **Status do Empreendimento:**
| Percentual Vendido | Status |
|--------------------|--------|
| 100% | "100% Vendido" |
| 90-99% | "Últimas Unidades" |
| 50-89% | "Em Comercialização" |
| 1-49% | "Lançamento" |
| 0% | "Em Breve" |

### **Status de Venda:**
| Percentual Vendido | StatusVenda |
|--------------------|-------------|
| 100% | "esgotado" |
| 90-99% | "ultimas_unidades" |
| 70-89% | "alta_procura" |
| 30-69% | "vendendo_bem" |
| 1-29% | "lancamento" |
| 0% | "disponivel" |

## 🔧 **Como Funciona:**

1. **Busca Empreendimentos** com relacionamento `unidades`
2. **Calcula Estatísticas** usando o accessor `getStatisticsAttribute()`
3. **Conta unidades por status:**
   - Status ID 1 = Disponível
   - Status ID 3 = Vendida
4. **Calcula percentual** de vendas
5. **Define status dinâmico** baseado no percentual

## 📊 **Mapeamento de Status das Unidades:**

```json
{
    "1": "Disponível",
    "2": "Reservada", 
    "3": "Vendida",
    "4": "Em Contrato",
    "5": "Em Manutenção"
}
```

## 🎯 **Uso Frontend:**

### **Exibir Progresso de Vendas:**
```javascript
const progressBar = `${imovel.percentualVendido}%`;
const statusClass = imovel.statusVenda; // 'vendendo_bem', 'alta_procura', etc
const disponibilidade = `${imovel.unidadesDisponiveis} de ${imovel.totalUnidades} disponíveis`;
```

### **Badges/Chips:**
```javascript
if (imovel.percentualVendido >= 90) {
    showBadge("Últimas Unidades", "warning");
} else if (imovel.percentualVendido >= 70) {
    showBadge("Alta Procura", "info");
}
```

## 💡 **Observações:**

1. **Performance:** Usa relacionamentos otimizados com eager loading
2. **Flexibilidade:** Status calculados dinamicamente baseados nos dados reais
3. **Preço Real:** Agora usa o valor médio das unidades cadastradas
4. **Compatibilidade:** Mantém todos os campos existentes

## ⚠️ **Status Atual:**

No momento, como não há unidades cadastradas no banco, os campos retornam:
- `totalUnidades`: 0
- `unidadesVendidas`: 0  
- `percentualVendido`: 0
- `unidadesDisponiveis`: 0
- `status`: "Em Breve"

**Para testar com dados reais, é necessário cadastrar unidades nas torres dos empreendimentos através da API `/torres/{id}/unidades`.**

## 🚀 **Próximos Passos:**

1. Cadastrar unidades de exemplo via API
2. Testar cálculos com dados reais
3. Ajustar frontend para usar os novos campos

**✅ Implementação completa das estatísticas de unidades na API de imóveis!**
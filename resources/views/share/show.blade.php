<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $entityData['nome'] ?? 'Compartilhamento' }} | Valeincorp</title>
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:title" content="{{ $entityData['nome'] ?? 'Imóvel' }} | Valeincorp">
    <meta property="og:description" content="Confira este {{ $compartilhamento->entity_type === 'empreendimento' ? 'empreendimento' : 'unidade' }} incrível!">
    
    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: linear-gradient(135deg, #0a1628 0%, #1a365d 100%);
            min-height: 100vh;
            color: #fff;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            padding: 40px 20px;
        }
        
        .logo {
            width: 180px;
            margin-bottom: 20px;
        }
        
        .card {
            background: #fff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            color: #1a1a1a;
        }
        
        .card-image {
            width: 100%;
            height: 300px;
            background: linear-gradient(135deg, #c9a227 0%, #dbb94a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .card-image svg {
            width: 80px;
            height: 80px;
            fill: #fff;
        }
        
        .card-body {
            padding: 24px;
        }
        
        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 12px;
        }
        
        .badge-empreendimento {
            background: #c9a227;
            color: #fff;
        }
        
        .badge-unidade {
            background: #22c55e;
            color: #fff;
        }
        
        .title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 16px;
            color: #0a1628;
        }
        
        .description {
            color: #666;
            line-height: 1.6;
            margin-bottom: 24px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        
        .info-item {
            padding: 16px;
            background: #f8f9fa;
            border-radius: 12px;
        }
        
        .info-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 4px;
        }
        
        .info-value {
            font-size: 16px;
            font-weight: 600;
            color: #0a1628;
        }
        
        .address {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 16px;
            background: #f0f9ff;
            border-radius: 12px;
            margin-bottom: 24px;
        }
        
        .address svg {
            width: 24px;
            height: 24px;
            fill: #0a1628;
            flex-shrink: 0;
            margin-top: 2px;
        }
        
        .address-text {
            color: #333;
            line-height: 1.5;
        }
        
        .cta-button {
            display: block;
            width: 100%;
            padding: 16px 24px;
            background: linear-gradient(135deg, #0a1628 0%, #1a365d 100%);
            color: #fff;
            text-align: center;
            text-decoration: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(10, 22, 40, 0.3);
        }
        
        .footer {
            text-align: center;
            padding: 40px 20px;
            color: rgba(255, 255, 255, 0.6);
            font-size: 14px;
        }
        
        .corretor-info {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px;
            background: #f8f9fa;
            border-radius: 12px;
            margin-top: 16px;
        }
        
        .corretor-avatar {
            width: 48px;
            height: 48px;
            background: #c9a227;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 600;
            font-size: 18px;
        }
        
        .corretor-name {
            font-weight: 600;
            color: #0a1628;
        }
        
        .corretor-label {
            font-size: 12px;
            color: #666;
        }
        
        @media (max-width: 600px) {
            .title {
                font-size: 22px;
            }
            
            .card-image {
                height: 200px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://backend.valeincorp.com.br/storage/images/logo-valeincorp.png" alt="Valeincorp" class="logo" onerror="this.style.display='none'">
        </div>
        
        <div class="card">
            <div class="card-image">
                <svg viewBox="0 0 24 24">
                    @if($compartilhamento->entity_type === 'empreendimento')
                    <path d="M17 11V3H7v4H3v14h8v-4h2v4h8V11h-4zM7 19H5v-2h2v2zm0-4H5v-2h2v2zm0-4H5V9h2v2zm4 4H9v-2h2v2zm0-4H9V9h2v2zm0-4H9V5h2v2zm4 8h-2v-2h2v2zm0-4h-2V9h2v2zm0-4h-2V5h2v2zm4 12h-2v-2h2v2zm0-4h-2v-2h2v2z"/>
                    @else
                    <path d="M12 3L2 12h3v8h6v-6h2v6h6v-8h3L12 3zm0 2.84L19 13h-1v6h-4v-6H10v6H6v-6H5l7-7.16z"/>
                    @endif
                </svg>
            </div>
            
            <div class="card-body">
                <span class="badge {{ $compartilhamento->entity_type === 'empreendimento' ? 'badge-empreendimento' : 'badge-unidade' }}">
                    {{ $compartilhamento->entity_type === 'empreendimento' ? 'Empreendimento' : 'Unidade' }}
                </span>
                
                <h1 class="title">{{ $entityData['nome'] ?? 'N/A' }}</h1>
                
                @if(isset($entityData['descricao']) && $entityData['descricao'])
                <p class="description">{{ $entityData['descricao'] }}</p>
                @endif
                
                @if(isset($entityData['endereco']))
                <div class="address">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                    </svg>
                    <div class="address-text">
                        {{ $entityData['endereco']['logradouro'] ?? '' }}
                        @if(isset($entityData['endereco']['numero'])), {{ $entityData['endereco']['numero'] }}@endif
                        <br>
                        {{ $entityData['endereco']['bairro'] ?? '' }}
                        @if(isset($entityData['endereco']['cidade'])) - {{ $entityData['endereco']['cidade'] }}@endif
                        @if(isset($entityData['endereco']['estado']))/{{ $entityData['endereco']['estado'] }}@endif
                    </div>
                </div>
                @endif
                
                @if(isset($entityData['espelho_vendas']))
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Total de Unidades</div>
                        <div class="info-value">{{ $entityData['espelho_vendas']['total_unidades'] ?? 0 }}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Disponíveis</div>
                        <div class="info-value">{{ $entityData['espelho_vendas']['unidades_disponiveis'] ?? 0 }}</div>
                    </div>
                </div>
                @endif
                
                <a href="https://app.valeincorp.com.br" class="cta-button">
                    Ver mais detalhes no App
                </a>
                
                @if($compartilhamento->corretor)
                <div class="corretor-info">
                    <div class="corretor-avatar">
                        {{ strtoupper(substr($compartilhamento->corretor->nome ?? 'C', 0, 1)) }}
                    </div>
                    <div>
                        <div class="corretor-name">{{ $compartilhamento->corretor->nome ?? 'Corretor' }}</div>
                        <div class="corretor-label">Corretor responsável</div>
                    </div>
                </div>
                @endif
            </div>
        </div>
        
        <div class="footer">
            <p>Compartilhado via Valeincorp</p>
            <p>© {{ date('Y') }} Valeincorp. Todos os direitos reservados.</p>
        </div>
    </div>
</body>
</html>


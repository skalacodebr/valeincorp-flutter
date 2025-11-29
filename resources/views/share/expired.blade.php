<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Link Expirado | Valeincorp</title>
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
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            padding: 20px;
        }
        
        .container {
            text-align: center;
            max-width: 500px;
        }
        
        .icon {
            width: 100px;
            height: 100px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
        }
        
        .icon svg {
            width: 50px;
            height: 50px;
            fill: #c9a227;
        }
        
        h1 {
            font-size: 32px;
            margin-bottom: 16px;
            font-weight: 700;
        }
        
        p {
            font-size: 16px;
            color: rgba(255, 255, 255, 0.7);
            line-height: 1.6;
            margin-bottom: 32px;
        }
        
        .button {
            display: inline-block;
            padding: 14px 32px;
            background: #c9a227;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(201, 162, 39, 0.3);
        }
        
        .footer {
            margin-top: 60px;
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">
            <svg viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15h2v2h-2v-2zm0-8h2v6h-2V9z"/>
            </svg>
        </div>
        
        <h1>Link Expirado</h1>
        
        <p>
            Este link de compartilhamento não está mais disponível. 
            Ele pode ter expirado ou sido desativado pelo corretor.
        </p>
        
        <a href="https://app.valeincorp.com.br" class="button">
            Acessar Valeincorp
        </a>
        
        <div class="footer">
            <p>© {{ date('Y') }} Valeincorp. Todos os direitos reservados.</p>
        </div>
    </div>
</body>
</html>


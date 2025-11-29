@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="min-h-screen bg-gray-100">
    <nav class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <h1 class="text-xl font-bold">Dashboard - CRM Vale Incorp</h1>
                </div>
                <div class="flex items-center">
                    <button id="logout-button" class="ml-4 px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                        Logout
                    </button>
                </div>
            </div>
        </div>
    </nav>

    <main class="py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <!-- Indicadores Principais -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Total Clientes</dt>
                                    <dd id="total-clientes" class="text-lg font-medium text-gray-900">
                                        <div class="animate-pulse bg-gray-300 h-4 w-8 rounded"></div>
                                    </dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M4 4a2 2 0 00-2 2v4a2 2 0 002 2V6h10a2 2 0 00-2-2H4zm2 6a2 2 0 012-2h8a2 2 0 012 2v4a2 2 0 01-2 2H8a2 2 0 01-2-2v-4zm6 4a2 2 0 100-4 2 2 0 000 4z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Total Negociações</dt>
                                    <dd id="total-negociacoes" class="text-lg font-medium text-gray-900">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-yellow-500 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Total Leads</dt>
                                    <dd id="total-leads" class="text-lg font-medium text-gray-900">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-purple-500 rounded-full flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Empreendimentos</dt>
                                    <dd id="total-empreendimentos" class="text-lg font-medium text-gray-900">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Gráfico de Clientes por Status -->
            <div class="bg-white overflow-hidden shadow rounded-lg mb-8">
                <div class="px-4 py-5 sm:px-6">
                    <h3 class="text-lg leading-6 font-medium text-gray-900">Clientes por Status</h3>
                </div>
                <div class="px-4 py-5">
                    <canvas id="clientes-status-chart" width="400" height="300"></canvas>
                </div>
            </div>

            <!-- Gráfico de Valores -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
                <!-- Valor Total por Mês -->
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="px-4 py-5 sm:px-6">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Valor Total das Negociações por Mês</h3>
                    </div>
                    <div class="px-4 py-5">
                        <canvas id="valor-mensal-chart" width="400" height="300"></canvas>
                    </div>
                </div>

                <!-- Top 5 Empreendimentos -->
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="px-4 py-5 sm:px-6">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Top 5 Empreendimentos</h3>
                    </div>
                    <div class="px-4 py-5">
                        <canvas id="empreendimentos-top-chart" width="400" height="300"></canvas>
                    </div>
                </div>
            </div>

            <!-- Tabelas de Resumo -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Tabela de Negociações Recentes -->
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="px-4 py-5 sm:px-6">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Negociações Recentes</h3>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                                </tr>
                            </thead>
                            <tbody id="negociacoes-recentes" class="bg-white divide-y divide-gray-200">
                                <tr>
                                    <td colspan="4" class="px-6 py-4 text-center text-gray-500">Carregando...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tabela de Clientes Recentes -->
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="px-4 py-5 sm:px-6">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">Clientes Recentes</h3>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                                </tr>
                            </thead>
                            <tbody id="clientes-recentes" class="bg-white divide-y divide-gray-200">
                                <tr>
                                    <td colspan="4" class="px-6 py-4 text-center text-gray-500">Carregando...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Perfil do Usuário (movido para o final) -->
            <div class="bg-white shadow overflow-hidden sm:rounded-lg mt-8">
                <div class="px-4 py-5 sm:px-6">
                    <h3 class="text-lg leading-6 font-medium text-gray-900">Perfil do Usuário</h3>
                    <p class="mt-1 max-w-2xl text-sm text-gray-500">Informações pessoais</p>
                </div>
                <div class="border-t border-gray-200">
                    <dl>
                        <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                            <dt class="text-sm font-medium text-gray-500">Nome completo</dt>
                            <dd id="user-name" class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Carregando...</dd>
                        </div>
                        <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                            <dt class="text-sm font-medium text-gray-500">Endereço de email</dt>
                            <dd id="user-email" class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">Carregando...</dd>
                        </div>
                    </dl>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Check if user is not logged in
    if (!localStorage.getItem('token')) {
        window.location.href = '{{ route('login') }}';
        return;
    }
    
    const userName = document.getElementById('user-name');
    const userEmail = document.getElementById('user-email');
    const logoutButton = document.getElementById('logout-button');
    
    // Variáveis para os gráficos
    let clientesStatusChart;
    let valorMensalChart;
    let empreendimentosTopChart;

    // Headers padrão para requisições
    const getHeaders = () => ({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
    });
    
    // Função para buscar dados da API
    async function fetchData(endpoint) {
        try {
            const response = await fetch(endpoint, {
                method: 'GET',
                headers: getHeaders()
            });
            
            if (!response.ok) {
                throw new Error(`Failed to fetch ${endpoint}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error(`Error fetching ${endpoint}:`, error);
            if (error.message.includes('401') || error.message.includes('Unauthorized')) {
                localStorage.removeItem('token');
                localStorage.removeItem('user');
                window.location.href = '{{ route('login') }}';
            }
            return null;
        }
    }

    // Atualizar dashboard com dados consolidados
    async function updateDashboardData() {
        const stats = await fetchData('/api/dashboard/stats');
        if (!stats) {
            console.log('Dados de estatísticas não disponíveis');
            return;
        }

        try {
            // Atualizar indicadores
            document.getElementById('total-clientes').innerHTML = stats.totals?.clientes || 0;
            document.getElementById('total-negociacoes').innerHTML = stats.totals?.negociacoes || 0;
            document.getElementById('total-leads').innerHTML = stats.totals?.leads || 0;
            document.getElementById('total-empreendimentos').innerHTML = stats.totals?.empreendimentos || 0;

            // Criar gráficos com verificação de dados
            if (stats.clientes_status && stats.clientes_status.length > 0) {
                createClientesStatusChart(stats.clientes_status);
            } else {
                console.log('Nenhum dado de status de clientes encontrado');
            }

            if (stats.valor_mensal && stats.valor_mensal.length > 0) {
                createValorMensalChart(stats.valor_mensal);
            } else {
                console.log('Nenhum dado de valor mensal encontrado');
            }

            if (stats.top_empreendimentos && stats.top_empreendimentos.length > 0) {
                createEmpreendimentosTopChart(stats.top_empreendimentos);
            } else {
                console.log('Nenhum dado de top empreendimentos encontrado');
            }

        } catch (error) {
            console.error('Erro ao atualizar dashboard:', error);
        }
    }


    // Gráfico de Clientes por Status (otimizado)
    function createClientesStatusChart(statusData) {
        if (!statusData || statusData.length === 0) {
            console.log('Dados de clientes por status vazios ou inválidos');
            return;
        }

        // Destruir gráfico anterior se existir
        if (clientesStatusChart) {
            clientesStatusChart.destroy();
        }

        // Validar e filtrar dados válidos
        const validData = statusData.filter(item => 
            item && typeof item.nome === 'string' && item.nome.trim() !== '' && 
            typeof item.count === 'number' && item.count >= 0
        );

        if (validData.length === 0) {
            console.log('Nenhum dado válido para o gráfico de clientes');
            return;
        }

        const labels = validData.map(item => item.nome);
        const data = validData.map(item => item.count);

        console.log('Criando gráfico de clientes com dados:', { labels, data });

        const ctx = document.getElementById('clientes-status-chart').getContext('2d');
        clientesStatusChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: [
                        '#10B981', '#3B82F6', '#F59E0B', '#EF4444',
                        '#8B5CF6', '#06B6D4', '#84CC16', '#F97316'
                    ],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `${context.label}: ${context.formattedValue} clientes`;
                            }
                        }
                    }
                }
            }
        });
    }


    // Gráfico de Valor Mensal
    function createValorMensalChart(valorData) {
        if (!valorData || valorData.length === 0) return;

        // Destruir gráfico anterior se existir
        if (valorMensalChart) {
            valorMensalChart.destroy();
        }

        const labels = valorData.map(item => item.mes);
        const data = valorData.map(item => item.valor);

        const ctx = document.getElementById('valor-mensal-chart').getContext('2d');
        valorMensalChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Valor Total (R$)',
                    data: data,
                    backgroundColor: 'rgba(34, 197, 94, 0.8)',
                    borderColor: '#22C55E',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return 'R$ ' + Number(context.formattedValue).toLocaleString('pt-BR', {minimumFractionDigits: 2});
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'R$ ' + Number(value).toLocaleString('pt-BR', {
                                    minimumFractionDigits: 0,
                                    maximumFractionDigits: 0
                                });
                            }
                        }
                    }
                }
            }
        });
    }

    // Gráfico Top 5 Empreendimentos
    function createEmpreendimentosTopChart(empreendimentosData) {
        if (!empreendimentosData || empreendimentosData.length === 0) return;

        // Destruir gráfico anterior se existir
        if (empreendimentosTopChart) {
            empreendimentosTopChart.destroy();
        }

        const labels = empreendimentosData.map(item => item.nome);
        const data = empreendimentosData.map(item => item.count);

        const ctx = document.getElementById('empreendimentos-top-chart').getContext('2d');
        empreendimentosTopChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Negociações',
                    data: data,
                    backgroundColor: [
                        '#8B5CF6', '#3B82F6', '#10B981', '#F59E0B', '#EF4444'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `${context.formattedValue} negociações`;
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        ticks: {
                            precision: 0
                        }
                    }
                }
            }
        });
    }

    // Atualizar tabelas
    async function updateTabelas() {
        // Negociações Recentes
        const negociacoes = await fetchData('/api/negociacoes');
        if (negociacoes) {
            const data = (negociacoes.data || negociacoes).slice(0, 5);
            const tbody = document.getElementById('negociacoes-recentes');
            
            if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center text-gray-500">Nenhuma negociação encontrada</td></tr>';
            } else {
                tbody.innerHTML = data.map(negociacao => `
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            ${negociacao.cliente?.pessoa?.nome || 'N/A'}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            ${negociacao.valor_contrato ? 'R$ ' + Number(negociacao.valor_contrato).toLocaleString('pt-BR', {minimumFractionDigits: 2}) : 'N/A'}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                ${negociacao.status?.nome || 'Sem Status'}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            ${new Date(negociacao.created_at).toLocaleDateString('pt-BR')}
                        </td>
                    </tr>
                `).join('');
            }
        }
        
        // Clientes Recentes
        const clientes = await fetchData('/api/clientes');
        if (clientes) {
            const data = (clientes.data || clientes).slice(0, 5);
            const tbody = document.getElementById('clientes-recentes');
            
            if (data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="px-6 py-4 text-center text-gray-500">Nenhum cliente encontrado</td></tr>';
            } else {
                tbody.innerHTML = data.map(cliente => `
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            ${cliente.pessoa?.nome || 'N/A'}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            ${cliente.pessoa?.email || 'N/A'}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                ${cliente.status?.nome || 'Sem Status'}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            ${new Date(cliente.created_at).toLocaleDateString('pt-BR')}
                        </td>
                    </tr>
                `).join('');
            }
        }
    }

    // Fetch user profile
    async function fetchProfile() {
        try {
            const response = await fetch('/api/me', {
                method: 'GET',
                headers: getHeaders()
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch profile');
            }
            
            const user = await response.json();
            
            // Update UI with user data
            userName.textContent = user.nome || user.name;
            userEmail.textContent = user.email;
            
        } catch (error) {
            console.error('Error fetching profile:', error);
            if (error.message.includes('401') || error.message.includes('Unauthorized')) {
                localStorage.removeItem('token');
                localStorage.removeItem('user');
                window.location.href = '{{ route('login') }}';
            }
        }
    }
    
    // Logout function
    logoutButton.addEventListener('click', async function() {
        try {
            const response = await fetch('/api/logout', {
                method: 'POST',
                headers: getHeaders()
            });
            
            // Clear localStorage and redirect regardless of response
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '{{ route('login') }}';
            
        } catch (error) {
            console.error('Error during logout:', error);
            // Still clear localStorage and redirect even if there's an error
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            window.location.href = '{{ route('login') }}';
        }
    });
    
    // Inicializar dashboard
    async function initDashboard() {
        await fetchProfile();
        await updateDashboardData();
        await updateTabelas();
    }
    
    // Inicializar tudo
    initDashboard();
    
    // Atualizar dados a cada 5 minutos
    setInterval(async () => {
        await updateDashboardData();
        await updateTabelas();
    }, 300000);
});
</script>
@endsection 
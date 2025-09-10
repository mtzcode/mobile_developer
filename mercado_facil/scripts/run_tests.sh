#!/bin/bash

# Script para executar todos os testes do Mercado Fácil
# Uso: ./scripts/run_tests.sh [tipo]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar se o comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar se estamos no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    print_error "Execute este script no diretório raiz do projeto Flutter"
    exit 1
fi

# Verificar se Flutter está instalado
if ! command_exists flutter; then
    print_error "Flutter não está instalado ou não está no PATH"
    exit 1
fi

# Função para executar testes unitários
run_unit_tests() {
    print_message "Executando testes unitários..."
    
    # Limpar cache se necessário
    if [ "$1" = "--clean" ]; then
        print_message "Limpando cache..."
        flutter clean
        flutter pub get
    fi
    
    # Executar testes unitários
    flutter test test/unit/ --coverage --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "Testes unitários executados com sucesso!"
    else
        print_error "Falha nos testes unitários"
        exit 1
    fi
}

# Função para executar testes de widget
run_widget_tests() {
    print_message "Executando testes de widget..."
    
    flutter test test/widget/ --coverage --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "Testes de widget executados com sucesso!"
    else
        print_error "Falha nos testes de widget"
        exit 1
    fi
}

# Função para executar testes de integração
run_integration_tests() {
    print_message "Executando testes de integração..."
    
    flutter test test/integration/ --coverage --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "Testes de integração executados com sucesso!"
    else
        print_error "Falha nos testes de integração"
        exit 1
    fi
}

# Função para executar todos os testes
run_all_tests() {
    print_message "Executando todos os testes..."
    
    # Executar todos os testes
    flutter test --coverage --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "Todos os testes executados com sucesso!"
    else
        print_error "Falha nos testes"
        exit 1
    fi
}

# Função para gerar relatório de cobertura
generate_coverage_report() {
    print_message "Gerando relatório de cobertura..."
    
    # Verificar se genhtml está disponível
    if command_exists genhtml; then
        # Criar diretório de cobertura se não existir
        mkdir -p coverage/html
        
        # Gerar relatório HTML
        genhtml coverage/lcov.info -o coverage/html
        
        if [ $? -eq 0 ]; then
            print_success "Relatório de cobertura gerado em coverage/html/"
            print_message "Abra coverage/html/index.html no navegador para visualizar"
        else
            print_error "Falha ao gerar relatório de cobertura"
            exit 1
        fi
    else
        print_warning "genhtml não está instalado. Instale o lcov para gerar relatórios HTML"
        print_message "Relatório de cobertura disponível em coverage/lcov.info"
    fi
}

# Função para mostrar estatísticas de cobertura
show_coverage_stats() {
    print_message "Estatísticas de cobertura:"
    
    if [ -f "coverage/lcov.info" ]; then
        # Extrair estatísticas básicas
        total_lines=$(grep -c "LF:" coverage/lcov.info || echo "0")
        covered_lines=$(grep -c "LH:" coverage/lcov.info || echo "0")
        
        if [ "$total_lines" -gt 0 ]; then
            coverage_percent=$((covered_lines * 100 / total_lines))
            print_message "Linhas cobertas: $covered_lines/$total_lines ($coverage_percent%)"
        else
            print_warning "Não foi possível calcular a cobertura"
        fi
    else
        print_warning "Arquivo de cobertura não encontrado"
    fi
}

# Função para limpar arquivos de cobertura
clean_coverage() {
    print_message "Limpando arquivos de cobertura..."
    
    rm -rf coverage/
    print_success "Arquivos de cobertura removidos"
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo "  unit              Executar apenas testes unitários"
    echo "  widget            Executar apenas testes de widget"
    echo "  integration       Executar apenas testes de integração"
    echo "  all               Executar todos os testes (padrão)"
    echo "  coverage          Gerar relatório de cobertura"
    echo "  stats             Mostrar estatísticas de cobertura"
    echo "  clean             Limpar arquivos de cobertura"
    echo "  --clean           Limpar cache antes de executar testes"
    echo "  help              Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                # Executar todos os testes"
    echo "  $0 unit           # Executar apenas testes unitários"
    echo "  $0 all --clean    # Limpar cache e executar todos os testes"
    echo "  $0 coverage       # Gerar relatório de cobertura"
}

# Verificar argumentos
case "${1:-all}" in
    "unit")
        run_unit_tests "$2"
        ;;
    "widget")
        run_widget_tests
        ;;
    "integration")
        run_integration_tests
        ;;
    "all")
        run_all_tests
        ;;
    "coverage")
        generate_coverage_report
        ;;
    "stats")
        show_coverage_stats
        ;;
    "clean")
        clean_coverage
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Opção inválida: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

# Se executou testes, mostrar estatísticas
if [[ "$1" =~ ^(unit|widget|integration|all)$ ]]; then
    echo ""
    show_coverage_stats
fi

print_success "Script executado com sucesso!" 
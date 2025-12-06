#!/bin/bash

# ===================================================================================
# Script para ejecutar benchmarks de implementaciones de Mandelbrot
# en C++, Haskell y Rust, y guardar los resultados en un archivo.
# ===================================================================================

# --- Configuración ---
RESULTS_FILE="benchmark_results.txt"
CPP_DIR="cpp-part"
HASKELL_DIR="h-part"
RUST_DIR="r-part"

# --- Funciones Auxiliares ---

# Imprime un mensaje de encabezado
function print_header {
    echo "================================================="
    echo "$1"
    echo "================================================="
}

# --- Preparación ---

# Limpiar el archivo de resultados anterior
echo "Resultados del Benchmark de Mandelbrot" > "$RESULTS_FILE"
echo "Ejecutado el: $(date)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"


# --- Benchmark C++ ---
print_header "Ejecutando Benchmark C++"
(
    cd "$CPP_DIR" || exit
    # Compilar si el ejecutable no existe
    if [ ! -f "tema-dos" ]; then
        echo "Compilando el código C++..."
        make
    fi
    echo "Ejecutando..."
    # Ejecutar y extraer el tiempo de ejecución
    CPP_TIME=$(./tema-dos | grep "Tiempo de ejecucion" | awk '{print $4}')
    echo "C++: $CPP_TIME s" >> "../$RESULTS_FILE"
    echo "Benchmark C++ completado."
)
echo ""


# --- Benchmark Haskell ---
print_header "Ejecutando Benchmark Haskell"
(
    cd "$HASKELL_DIR" || exit
    # Cabal se encarga de la compilación, pero buscamos el ejecutable
    HASKELL_EXE=$(find dist-newstyle -name "tema-dos" -type f -executable | head -n 1)
    if [ -z "$HASKELL_EXE" ]; then
        echo "Construyendo el proyecto Haskell..."
        cabal build
        HASKELL_EXE=$(find dist-newstyle -name "tema-dos" -type f -executable | head -n 1)
    fi

    if [ -f "$HASKELL_EXE" ]; then
        echo "Ejecutando..."
        # Ejecutar y extraer el tiempo de ejecución
        HASKELL_TIME=$($HASKELL_EXE | grep "Tiempo de ejecucion" | awk '{print $4}')
        echo "Haskell: $HASKELL_TIME s" >> "../$RESULTS_FILE"
        echo "Benchmark Haskell completado."
    else
        echo "Error: No se encontró el ejecutable de Haskell." | tee -a "../$RESULTS_FILE"
    fi
)
echo ""


# --- Benchmark Rust ---
print_header "Ejecutando Benchmark Rust"
(
    cd "$RUST_DIR" || exit
    # Compilar en modo release si el ejecutable no existe
    if [ ! -f "target/release/tema-dos" ]; then
        echo "Compilando el código Rust (modo release)..."
        cargo build --release
    fi
    echo "Ejecutando..."
    # Ejecutar y extraer el tiempo de ejecución
    RUST_TIME=$(./target/release/tema-dos | grep "Tiempo de ejecucion" | awk '{print $4}')
    echo "Rust: $RUST_TIME s" >> "../$RESULTS_FILE"
    echo "Benchmark Rust completado."
)
echo ""


# --- Finalización ---
print_header "Resultados Finales"
cat "$RESULTS_FILE"
echo ""
echo "Los resultados han sido guardados en '$RESULTS_FILE'."

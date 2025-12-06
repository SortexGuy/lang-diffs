# Comparativa de Rendimiento: C++, Haskell y Rust

Este proyecto compara la implementación y el rendimiento de un mismo algoritmo computacionalmente intensivo en tres lenguajes de programación diferentes: C++, Haskell y Rust.

## El Algoritmo: Cálculo del Conjunto de Mandelbrot

El programa calcula una versión simplificada del [Conjunto de Mandelbrot](https://es.wikipedia.org/wiki/Conjunto_de_Mandelbrot). El objetivo es realizar una tarea numérica pesada para poder comparar el rendimiento de los lenguajes.

El algoritmo funciona de la siguiente manera:

1.  **Plano Complejo**: Se define una región en el plano complejo (un área con coordenadas reales e imaginarias).
2.  **Iteración por Píxel**: El programa itera sobre una cuadrícula de píxeles (en este caso, 2000x2000), donde cada píxel corresponde a un punto `c` en el plano complejo.
3.  **La Secuencia de Mandelbrot**: Para cada punto `c`, se calcula una secuencia de números complejos `z` comenzando con `z_0 = 0`, usando la fórmula recursiva:
    `z_{n+1} = z_n^2 + c`
4.  **Condición de Escape**: Se comprueba en cada iteración si el punto "escapa". Un punto escapa si el módulo (distancia desde el origen) de `z_n` se vuelve mayor que 2. Matemáticamente: `|z_n|^2 > 4`.
5.  **Conteo de Iteraciones**:
    *   Si el punto escapa, se cuenta el número de iteraciones que tardó en hacerlo.
    *   Si el punto no ha escapado después de un número máximo de iteraciones (`MAX_ITER`, aquí 1000), se asume que pertenece al conjunto de Mandelbrot y se detiene el cálculo para ese punto.
6.  **Suma Total**: El programa suma el total de iteraciones de todos los píxeles. Este valor final es el que se usa como métrica para el benchmark.

## Diferencias en las Implementaciones

Cada lenguaje aborda el problema siguiendo sus paradigmas y características idiomáticas.

### C++ (`cpp-part/`)

-   **Paradigma**: **Imperativo / Procedimental**.
-   **Estructura**: Utiliza bucles `for` anidados, la forma más tradicional y directa de iterar sobre la cuadrícula de píxeles.
-   **Rendimiento**: El código es de bajo nivel y, compilado con optimizaciones agresivas (`-O3 -march=native`), logra un rendimiento excelente al darle al compilador libertad para usar las instrucciones específicas del procesador.
-   **Memoria**: La gestión de memoria es manual, aunque en este caso simple, todas las variables se alojan en la pila (`stack`), lo que es muy eficiente.

```cpp
// Bucle anidado para recorrer cada píxel de la imagen.
for (int py = 0; py < HEIGHT; ++py) {
    for (int px = 0; px < WIDTH; ++px) {
        // ...
        total_iterations += mandelbrot_pixel(cx, cy);
    }
}
```

### Haskell (`h-part/`)

-   **Paradigma**: **Funcional Puro**.
-   **Estructura**: No hay bucles ni variables mutables. En su lugar, se usan funciones de orden superior. La iteración se logra con `foldl'` (un "fold" estricto) anidado.
-   **Inmutabilidad y Pereza**: Haskell es perezoso por defecto, lo que puede causar problemas de rendimiento ("space leaks") en código numérico. Para evitarlo, se usan:
    -   `BangPatterns` (`!iter`): para forzar la evaluación estricta de los argumentos en la función recursiva.
    -   `foldl'`: una versión estricta de `foldl` que evalúa el acumulador en cada paso.
-   **Recursión de Cola**: La función `mandelPixel` se implementa con recursión de cola para que el compilador la optimice a un bucle eficiente.

```haskell
-- El `foldl'` externo itera sobre las filas (coordenada Y).
let totalIterations = foldl' (\accY py ->
        -- El `foldl'` interno itera sobre las columnas (coordenada X).
        accY + foldl' (\accX px ->
              accX + mandelPixel cx cy
            ) 0 [0..width-1]
      ) 0 [0..height-1]
```

### Rust (`r-part/`)

-   **Paradigma**: **Imperativo con un fuerte enfoque en la seguridad y la concurrencia**.
-   **Estructura**: Usa bucles `for` sobre rangos (`0..HEIGHT`), similar a C++, pero con las garantías de seguridad de Rust.
-   **Seguridad de Memoria**: El sistema de *ownership* y *borrowing* de Rust garantiza que no haya errores de memoria (como `null pointers` o `data races`) en tiempo de compilación, sin necesidad de un recolector de basura (`garbage collector`).
-   **Rendimiento**: Ofrece un rendimiento comparable al de C++ ("zero-cost abstractions"), pero con un nivel de seguridad mucho más alto. El código se compila en modo `release` para aplicar las máximas optimizaciones.
-   **Tipado**: El sistema de tipos es estricto y expresivo, ayudando a prevenir errores comunes.

```rust
// Bucle anidado que recorre cada píxel.
for py in 0..HEIGHT {
    for px in 0..WIDTH {
        // ...
        total_iterations += mandelbrot_pixel(cx, cy) as u64;
    }
}
```

## Resultados del Benchmark

El script `run_benchmarks.sh` compila y ejecuta cada programa, extrayendo el tiempo de ejecución.

```
Resultados del Benchmark de Mandelbrot
Ejecutado el: vie 05 dic 2025 21:56:26 -04

C++: 3.39311 s
Haskell: 5.043771 s
Rust: 3.434236 s
```

### Análisis de Resultados

-   **C++ y Rust** muestran un rendimiento muy similar y son los más rápidos. Esto es esperable, ya que ambos son lenguajes compilados de bajo nivel diseñados para el máximo rendimiento.
-   **Haskell** es notablemente más lento en esta prueba. Aunque el código está optimizado (estricto y con recursión de cola), la sobrecarga de la abstracción funcional y el runtime de Haskell pueden introducir una penalización de rendimiento en cálculos numéricos intensivos como este, en comparación con el metal casi desnudo al que apuntan C++ y Rust.

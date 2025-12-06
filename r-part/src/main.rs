// Biblioteca estándar para la medición precisa del tiempo.
use std::time::Instant;

// =================================================================================================
// CONFIGURACIÓN GLOBAL
//
// Define las dimensiones de la imagen, el número máximo de iteraciones y los límites
// del plano complejo. `usize` es el tipo de dato apropiado para tamaños y conteos.
// =================================================================================================

const WIDTH: usize = 2000; // Ancho de la imagen en píxeles.
const HEIGHT: usize = 2000; // Alto de la imagen en píxeles.
const MAX_ITER: usize = 1000; // Número máximo de iteraciones por píxel.
const X_MIN: f64 = -2.0; // Límite inferior del eje real (coordenada X).
const X_MAX: f64 = 1.0; // Límite superior del eje real (coordenada X).
const Y_MIN: f64 = -1.0; // Límite inferior del eje imaginario (coordenada Y).
const Y_MAX: f64 = 1.0; // Límite superior del eje imaginario (coordenada Y).

// =================================================================================================
// FUNCIÓN `mandelbrot_pixel`
//
// Calcula el número de iteraciones para un punto específico (cx, cy) en el plano complejo.
// Sigue la misma lógica que las implementaciones en C++ y Haskell.
//
// Argumentos:
//   - cx: Parte real del número complejo (f64).
//   - cy: Parte imaginaria del número complejo (f64).
//
// Retorna:
//   El número de iteraciones realizadas (usize). En Rust, la última expresión de una
//   función sin un punto y coma es su valor de retorno implícito.
// =================================================================================================
fn mandelbrot_pixel(cx: f64, cy: f64) -> usize {
    let mut zx = 0.0;
    let mut zy = 0.0;
    let mut zx2 = 0.0;
    let mut zy2 = 0.0;
    let mut iter = 0;

    // Bucle `while` que se ejecuta mientras el punto no haya "escapado" y no se
    // haya alcanzado el máximo de iteraciones.
    while (zx2 + zy2 <= 4.0) && (iter < MAX_ITER) {
        // z_{n+1} = z_n^2 + c
        zy = 2.0 * zx * zy + cy;
        zx = zx2 - zy2 + cx;

        zx2 = zx * zx;
        zy2 = zy * zy;
        iter += 1;
    }
    // Retorno implícito del número de iteraciones.
    iter
}

// =================================================================================================
// FUNCIÓN `main`
//
// Punto de entrada del programa. Realiza el benchmark del cálculo de Mandelbrot.
// Itera sobre cada píxel, mapea a coordenadas complejas y suma las iteraciones.
// =================================================================================================
fn main() {
    println!("Iniciando benchmark Rust...");
    // Inicia la medición del tiempo. `Instant` es ideal para benchmarks.
    let start = Instant::now();

    // Acumulador para la suma total de iteraciones. `u64` para evitar desbordamientos.
    let mut total_iterations: u64 = 0;

    // Bucle anidado que recorre cada píxel. Rust usa rangos `0..N` que son exclusivos
    // en el límite superior, equivalente a `for (int i = 0; i < N; ++i)`.
    for py in 0..HEIGHT {
        let cy = Y_MIN + (py as f64 / HEIGHT as f64) * (Y_MAX - Y_MIN);

        for px in 0..WIDTH {
            let cx = X_MIN + (px as f64 / WIDTH as f64) * (X_MAX - X_MIN);

            // `mandelbrot_pixel` retorna `usize`, se convierte a `u64` para sumar.
            total_iterations += mandelbrot_pixel(cx, cy) as u64;
        }
    }

    // `start.elapsed()` calcula el tiempo transcurrido desde la creación de `start`.
    let duration = start.elapsed();

    // Muestra los resultados del benchmark.
    println!("Suma Total de Iteraciones: {}", total_iterations);
    // `as_secs_f64()` convierte la duración a un número de punto flotante de segundos.
    println!("Tiempo de ejecucion: {:.6} s", duration.as_secs_f64());
}

// Bibliotecas estándar para entrada/salida y medición del tiempo.
#include <iostream>
#include <chrono>

// ================================================================================================
// CONFIGURACIÓN GLOBAL
//
// Define las dimensiones de la imagen, el número máximo de iteraciones y los límites
// del plano complejo para el cálculo del conjunto de Mandelbrot.
// ================================================================================================

const int WIDTH = 2000;       // Ancho de la imagen en píxeles.
const int HEIGHT = 2000;      // Alto de la imagen en píxeles.
const int MAX_ITER = 1000;    // Número máximo de iteraciones por píxel.
const double X_MIN = -2.0;    // Límite inferior del eje real (coordenada X).
const double X_MAX = 1.0;     // Límite superior del eje real (coordenada X).
const double Y_MIN = -1.0;    // Límite inferior del eje imaginario (coordenada Y).
const double Y_MAX = 1.0;     // Límite superior del eje imaginario (coordenada Y).

// ================================================================================================
// FUNCIÓN `mandelbrot_pixel`
//
// Calcula el número de iteraciones para un punto específico (cx, cy) en el plano complejo
// hasta que el valor absoluto del número complejo z exceda 2, o se alcance `MAX_ITER`.
//
// Argumentos:
//   - cx: Parte real del número complejo.
//   - cy: Parte imaginaria del número complejo.
//
// Retorna:
//   El número de iteraciones realizadas. Un valor igual a `MAX_ITER` indica que el punto
//   probablemente pertenece al conjunto de Mandelbrot.
// =================================================================================================
int mandelbrot_pixel(double cx, double cy) {
    double zx = 0.0;     // Parte real de z, inicializada en 0.
    double zy = 0.0;     // Parte imaginaria de z, inicializada en 0.
    double zx2 = 0.0;    // Cuadrado de zx, para optimizar el cálculo.
    double zy2 = 0.0;    // Cuadrado de zy, para optimizar el cálculo.
    int iter = 0;        // Contador de iteraciones.

    // El bucle de Mandelbrot: z_{n+1} = z_n^2 + c
    // Se itera hasta que |z|^2 > 4 (el punto escapa) o se alcanza el límite de iteraciones.
    // |z|^2 se calcula como zx*zx + zy*zy.
    while (zx2 + zy2 <= 4.0 && iter < MAX_ITER) {
        // zy_{n+1} = 2 * zx_n * zy_n + cy
        zy = 2.0 * zx * zy + cy;
        // zx_{n+1} = zx_n^2 - zy_n^2 + cx
        zx = zx2 - zy2 + cx;

        // Pre-calculamos los cuadrados para la siguiente iteración y la condición del bucle.
        zx2 = zx * zx;
        zy2 = zy * zy;
        iter++;
    }
    return iter;
}

// =================================================================================================
// FUNCIÓN `main`
//
// Punto de entrada del programa. Realiza un benchmark del cálculo del conjunto de Mandelbrot.
// Itera sobre cada píxel de una imagen virtual, calcula el valor de Mandelbrot para
// las coordenadas correspondientes y suma todas las iteraciones.
//
// Mide y muestra el tiempo total de ejecución y la suma de iteraciones.
// =================================================================================================
int main() {
    std::cout << "Iniciando benchmark C++..." << std::endl;
    // Inicia la medición del tiempo.
    auto start = std::chrono::high_resolution_clock::now();

    long long total_iterations = 0; // Acumulador para la suma de todas las iteraciones.

    // Bucle anidado para recorrer cada píxel de la imagen.
    for (int py = 0; py < HEIGHT; ++py) {
        // Mapea la fila de píxeles (py) a la coordenada imaginaria (cy) en el plano complejo.
        double cy = Y_MIN + (double)py / HEIGHT * (Y_MAX - Y_MIN);

        for (int px = 0; px < WIDTH; ++px) {
            // Mapea la columna de píxeles (px) a la coordenada real (cx) en el plano complejo.
            double cx = X_MIN + (double)px / WIDTH * (X_MAX - X_MIN);
            
            // Calcula las iteraciones para el punto (cx, cy) y las suma al total.
            total_iterations += mandelbrot_pixel(cx, cy);
        }
    }

    // Detiene la medición del tiempo.
    auto end = std::chrono::high_resolution_clock::now();
    // Calcula la diferencia de tiempo.
    std::chrono::duration<double> diff = end - start;

    // Muestra los resultados del benchmark.
    std::cout << "Suma Total de Iteraciones: " << total_iterations << std::endl;
    std::cout << "Tiempo de ejecucion: " << diff.count() << " s" << std::endl;

    return 0;
}

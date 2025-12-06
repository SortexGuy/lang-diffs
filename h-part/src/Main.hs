-- =================================================================================================
-- PRAGMA DE LENGUAJE
--
-- Habilita `BangPatterns` para forzar la evaluación estricta de argumentos en funciones.
-- Esto es crucial para el rendimiento en código numérico como este, ya que evita la
-- acumulación de "thunks" (cálculos perezosos no evaluados) y reduce el consumo de memoria.
-- =================================================================================================
{-# LANGUAGE BangPatterns #-}

module Main where

-- Bibliotecas estándar para medición de tiempo, formato de texto y listas.
import System.CPUTime (getCPUTime)
import Text.Printf (printf)
import Data.List (foldl') -- Se usa foldl' (estricto) en lugar de foldl (perezoso).

-- =================================================================================================
-- CONFIGURACIÓN GLOBAL
--
-- Define las dimensiones, el número máximo de iteraciones y los límites del plano complejo.
-- =================================================================================================

width, height, maxIter :: Int
width = 2000       -- Ancho de la imagen en píxeles.
height = 2000      -- Alto de la imagen en píxeles.
maxIter = 1000     -- Número máximo de iteraciones por píxel.

xMin, xMax, yMin, yMax :: Double
xMin = -2.0    -- Límite inferior del eje real.
xMax = 1.0     -- Límite superior del eje real.
yMin = -1.0    -- Límite inferior del eje imaginario.
yMax = 1.0     -- Límite superior del eje imaginario.

-- =================================================================================================
-- FUNCIÓN `mandelPixel`
--
-- Calcula las iteraciones de Mandelbrot para un punto (cx, cy) usando recursión de cola.
-- La función `go` es una función auxiliar interna que lleva el estado de la iteración.
--
-- Argumentos:
--   - cx: Parte real del número complejo.
--   - cy: Parte imaginaria del número complejo.
--
-- Retorna:
--   El número de iteraciones.
-- =================================================================================================
mandelPixel :: Double -> Double -> Int
mandelPixel cx cy = go 0 0.0 0.0 0.0 0.0
  where
    -- Función recursiva de cola (`go`).
    -- Los `!` (Bang Patterns) fuerzan la evaluación de los argumentos en cada llamada,
    -- evitando la pereza y mejorando el rendimiento.
    go :: Int -> Double -> Double -> Double -> Double -> Int
    go !iter !zx !zy !zx2 !zy2
      | zx2 + zy2 > 4.0 = iter      -- Condición de escape: el punto divergió.
      | iter >= maxIter = iter      -- Condición de parada: se alcanzó el máximo de iteraciones.
      | otherwise =
          -- Cálculo del siguiente punto en la secuencia de Mandelbrot.
          let !newZy = 2.0 * zx * zy + cy
              !newZx = zx2 - zy2 + cx
          in go (iter + 1) newZx newZy (newZx * newZx) (newZy * newZy)

-- =================================================================================================
-- FUNCIÓN `main`
--
-- Punto de entrada del programa. Realiza el benchmark del cálculo de Mandelbrot.
-- Utiliza `foldl'` (un fold estricto) anidado para iterar sobre el plano complejo.
--
-- `foldl'` es preferible a `foldl` aquí porque evalúa el acumulador en cada paso,
-- previniendo la acumulación de cálculos perezosos que consumirían mucha memoria (space leak).
-- =================================================================================================
main :: IO ()
main = do
    putStrLn "Iniciando benchmark Haskell..."
    start <- getCPUTime -- Captura el tiempo de inicio de la CPU.

    -- El `foldl'` externo itera sobre las filas (coordenada Y).
    let totalIterations = foldl' (\accY py ->
            let cy = yMin + (fromIntegral py / fromIntegral height) * (yMax - yMin)
            -- El `foldl'` interno itera sobre las columnas (coordenada X) para cada fila.
            in accY + foldl' (\accX px ->
                  let cx = xMin + (fromIntegral px / fromIntegral width) * (xMax - xMin)
                  -- Se suma el resultado de `mandelPixel` al acumulador de la fila.
                  in accX + mandelPixel cx cy
                ) 0 [0..width-1] -- El rango de píxeles en X.
          ) 0 [0..height-1]      -- El rango de píxeles en Y.

    -- `print` fuerza la evaluación completa de `totalIterations`.
    -- Sin esto, debido a la pereza de Haskell, el cálculo no se ejecutaría hasta que se
    -- necesite el valor, y la medición del tiempo sería incorrecta.
    print totalIterations

    end <- getCPUTime -- Captura el tiempo de finalización.
    -- El tiempo se mide en picosegundos, por lo que se convierte a segundos.
    let diff = fromIntegral (end - start) / (10^(12 :: Integer)) :: Double
    printf "Tiempo de ejecucion: %.6f s\n" diff

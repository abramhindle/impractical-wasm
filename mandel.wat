;; https://rosettacode.org/wiki/Mandelbrot_set#PPM_non_interactive
;; GNU FDL
;; Rosetta Code
(module
 (import "env" "memory" (memory 1))
 ;; (memory $memory (export "memory") 1)
 (func $mandel (export "mandel") (param $cx f64) (param $cy f64) (param $maxiter i32) (result i32)
       (local $i i32)
       (local $zx f64)
       (local $zy f64)
       (local $zx2 f64)
       (local $zy2 f64)
       (set_local $i (i32.const 0))
       (set_local $zx (f64.const 0.0))
       (set_local $zy (f64.const 0.0))
       (set_local $zx2 (f64.const 0.0))
       (set_local $zy2 (f64.const 0.0))
       (block
           (loop
              (set_local $zy (f64.add
                              (get_local $cy)
                              (f64.mul
                               (f64.const 2.0)
                               (f64.mul (get_local $zx) (get_local $zy)))))
              (set_local $zx (f64.add
                              (get_local $cx)
                              (f64.sub (get_local $zx2) (get_local $zy2))))
              (set_local $zx2 (f64.mul (get_local $zx) (get_local $zx)))
              (set_local $zy2 (f64.mul (get_local $zy) (get_local $zy)))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br_if 1 (i32.eq (get_local $i) (get_local $maxiter)))
              (br_if 1 (f64.ge
                        (f64.add (get_local $zx2) (get_local $zy2)) (f64.const 4.0))) ;; escape value (2^2)
              (br 0)))
       (i32.eq (get_local $i) (get_local $maxiter))))

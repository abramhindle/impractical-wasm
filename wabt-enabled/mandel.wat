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
       (get_local $i))
 (func $drawMandel (export "drawMandel") (param $arr i32) (param $w i32) (param $h i32) (param $xscale f64) (param $xoff f64) (param $yscale f64) (param $yoff f64) (param $iters i32) (result i32)
       (local $i i32)
       (local $v i32)
       (local $x i32)
       (local $y i32)
       (local $cx f64)
       (local $cy f64)
       (set_local $y (i32.const 0))
       (set_local $x (i32.const 0))
       (set_local $i (i32.const 0))
       (block $yloop
           (loop
              (block $xloop
                (loop
                   ;; 2*x/(1.0*canvasWidth) - 1.5
                   (set_local $cx (f64.sub
                                   (f64.mul
                                    (get_local $xscale)
                                    (f64.div
                                     (f64.convert_s/i32 (get_local $x))
                                     (f64.convert_s/i32 (get_local $w))))
                                   (get_local $xoff)))
                   (set_local $cy (f64.sub
                                   (f64.mul
                                    (get_local $yscale)
                                    (f64.div
                                     (f64.convert_s/i32 (get_local $y))
                                     (f64.convert_s/i32 (get_local $h))))
                                   (get_local $yoff)))
                   (set_local $v (i32.and (i32.const 0xff)
                                          (call $mandel (get_local $cx) (get_local $cy) (get_local $iters))))
                   (i32.store8 (i32.add (get_local $i) (get_local $arr)) (get_local $v)) ;; r
                   (set_local $i (i32.add (get_local $i) (i32.const 1)))
                   (i32.store8 (i32.add (get_local $i) (get_local $arr)) (get_local $v)) ;; g
                   (set_local $i (i32.add (get_local $i) (i32.const 1)))
                   (i32.store8 (i32.add (get_local $i) (get_local $arr)) (get_local $v)) ;; b
                   (set_local $i (i32.add (get_local $i) (i32.const 1)))
                   (i32.store8 (i32.add (get_local $i) (get_local $arr)) (i32.const 0xff)) ;; alpha
                   (set_local $i (i32.add (get_local $i) (i32.const 1)))
                   (set_local $x (i32.add (get_local $x) (i32.const 1)))
                   (br_if 1 (i32.eq (get_local $x) (get_local $w)))
                   (br 0)))
            (set_local $y (i32.add (get_local $y) (i32.const 1)))
            (br_if 1 (i32.eq (get_local $y) (get_local $h)))
            (set_local $x (i32.const 0))
            (br 0)))
       (i32.const 1)))
                   
                   
                                


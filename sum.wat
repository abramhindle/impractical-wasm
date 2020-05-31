(module
  (import "env" "memory" (memory 512))
  ;; (memory $memory (export "memory") 1)
  (func $offset (param $arr i32) (param $i i32) (result i32)
      (i32.add
          (get_local $arr) 
          (i32.mul (i32.const 8) (get_local $i))     
      )
  )
  (func $asmSum (export "asmSum") (param $arr i32) (param $n i32) (result f64)
      (local $i i32)
      (local $o f64)
      (set_local $i (i32.const 0))
      (set_local $o (f64.const 0.0))
      (block
          (loop 
              (set_local $o
                  (f64.add
                      (f64.load (call $offset (get_local $arr) (get_local $i)))
                      (get_local $o)))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br_if 1 (i32.eq (get_local $i) (get_local $n)))
              (br 0)))
      (get_local $o))
  (func $asmSum2 (export "asmSum2") (param $arr i32) (param $n i32) (result f64)
      (local $i i32)
      (local $o f64)
      (set_local $i (i32.const 0))
      (set_local $o (f64.const 0.0))
      (block
          (loop 
              (set_local $o
                  (f64.add
                      (f64.load 
                                (i32.add
                                        (get_local $arr)
          		                (i32.mul (i32.const 8) (get_local $i))))
                      (get_local $o)))
              (set_local $i (i32.add (get_local $i) (i32.const 1)))
              (br_if 1 (i32.eq (get_local $i) (get_local $n)))
              (br 0)))
      (get_local $o)))


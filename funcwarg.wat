(module
  (func $funcWithArg (param $x i32) (result i32)
      (get_local $x))
  (func $main (export "main") (result i32)
      (call $funcWithArg (i32.const 22))))

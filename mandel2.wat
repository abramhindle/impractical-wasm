(module
  (type (;0;) (func (param f64 f64 i32) (result i32)))
  (import "env" "memory" (memory 1))
  (func $mandel (export "mandel") (type 0) (param f64 f64 i32) (result i32)
    (local i32 i32 i32 i32 f64 i32 i32 i32 i32 i32 i32 i32 i32 i32 f64 f64 f64 f64 i32 i32 i32 i32 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 f64 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 0
    local.set 3
    i32.const 64
    local.set 4
    local.get 3
    local.get 4
    i32.sub
    local.set 5
    i32.const 0
    local.set 6
    local.get 6
    f64.convert_i32_s
    local.set 7
    local.get 5
    local.get 0
    f64.store offset=56
    local.get 5
    local.get 1
    f64.store offset=48
    local.get 5
    local.get 2
    i32.store offset=44
    local.get 5
    local.get 6
    i32.store offset=40
    local.get 5
    local.get 7
    f64.store offset=32
    local.get 5
    local.get 7
    f64.store offset=24
    local.get 5
    local.get 7
    f64.store offset=16
    local.get 5
    local.get 7
    f64.store offset=8
    local.get 5
    local.get 6
    i32.store offset=40
    loop  ;; label = @1
      i32.const 0
      local.set 8
      local.get 5
      i32.load offset=40
      local.set 9
      local.get 5
      i32.load offset=44
      local.set 10
      local.get 9
      local.set 11
      local.get 10
      local.set 12
      local.get 11
      local.get 12
      i32.lt_s
      local.set 13
      i32.const 1
      local.set 14
      local.get 13
      local.get 14
      i32.and
      local.set 15
      local.get 8
      local.set 16
      block  ;; label = @2
        local.get 15
        i32.eqz
        br_if 0 (;@2;)
        f64.const 0x1p+2 (;=4;)
        local.set 17
        local.get 5
        f64.load offset=16
        local.set 18
        local.get 5
        f64.load offset=8
        local.set 19
        local.get 18
        local.get 19
        f64.add
        local.set 20
        local.get 20
        local.get 17
        f64.lt
        local.set 21
        local.get 21
        local.set 16
      end
      local.get 16
      local.set 22
      i32.const 1
      local.set 23
      local.get 22
      local.get 23
      i32.and
      local.set 24
      block  ;; label = @2
        local.get 24
        i32.eqz
        br_if 0 (;@2;)
        f64.const 0x1p+1 (;=2;)
        local.set 25
        local.get 5
        f64.load offset=48
        local.set 26
        local.get 5
        f64.load offset=32
        local.set 27
        local.get 25
        local.get 27
        f64.mul
        local.set 28
        local.get 5
        f64.load offset=24
        local.set 29
        local.get 28
        local.get 29
        f64.mul
        local.set 30
        local.get 26
        local.get 30
        f64.add
        local.set 31
        local.get 5
        local.get 31
        f64.store offset=24
        local.get 5
        f64.load offset=56
        local.set 32
        local.get 5
        f64.load offset=16
        local.set 33
        local.get 32
        local.get 33
        f64.add
        local.set 34
        local.get 5
        f64.load offset=8
        local.set 35
        local.get 34
        local.get 35
        f64.sub
        local.set 36
        local.get 5
        local.get 36
        f64.store offset=32
        local.get 5
        f64.load offset=32
        local.set 37
        local.get 5
        f64.load offset=32
        local.set 38
        local.get 37
        local.get 38
        f64.mul
        local.set 39
        local.get 5
        local.get 39
        f64.store offset=16
        local.get 5
        f64.load offset=24
        local.set 40
        local.get 5
        f64.load offset=24
        local.set 41
        local.get 40
        local.get 41
        f64.mul
        local.set 42
        local.get 5
        local.get 42
        f64.store offset=8
        local.get 5
        i32.load offset=40
        local.set 43
        i32.const 1
        local.set 44
        local.get 43
        local.get 44
        i32.add
        local.set 45
        local.get 5
        local.get 45
        i32.store offset=40
        br 1 (;@1;)
      end
    end
    local.get 5
    i32.load offset=40
    local.set 46
    local.get 5
    i32.load offset=44
    local.set 47
    local.get 46
    local.set 48
    local.get 47
    local.set 49
    local.get 48
    local.get 49
    i32.eq
    local.set 50
    i32.const 1
    local.set 51
    local.get 50
    local.get 51
    i32.and
    local.set 52
    local.get 52
    return))

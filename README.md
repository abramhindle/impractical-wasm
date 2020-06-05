# Introduction to Impractical WASM

#### Abram Hindle
#### <abram.hindle@ualberta.ca>
#### http://softwareprocess.ca/

Slide content under CC-BY-SA 4.0 and Apache 2.0 License for source
code. Slide Source code is MIT Licensed.


## WASM - WebAssembly

https://WebAssembly.org (June 4, 2020) states:

> WebAssembly (abbreviated Wasm) is a binary instruction format for a
> stack-based virtual machine. Wasm is designed as a portable target
> for compilation of high-level languages like C/C++/Rust, enabling
> deployment on the web for client and server applications.


## WASM - What I am covering today

- How to write WASM by hand.
- How to compile WASM
- Basics of WASM


## WASM - What I won't cover

- How to compile C to WASM (use LLVM and/or Emscripten)
- How to compile language X to WASM
- How to use assemblyscript or typescript
- WASM bytecode
- wat without sexpressions
- asm.js
- Emscripten


## WASM: Intents and impressions

- Safety: security is at the forefront. No one wants wasm to have less security scrutiny than javascript already has.
- Portable: It runs in almost every browser
- Fast enough: It runs at roughly the speed of equivalent Javascript.
- Binary format: fast loading, compact representation


## WASM: Immediate Limitations

- Security over performance
- You can't assemble in the browser without `linwabt.js`
- Difficult to share memory with javascript
- Lack of expected features making compiling to WASM somewhat difficult
  - GOTO
  - Visible stack
  - Pointers (without address there's real limits)
  - Nice interaction with typed arrays


## WASM: Quick Boot

Let's just jump right in

```wasm
(module
  (func $main (export "main") (result i32)
      (return (i32.const 42))))
```

```shell
wat2wasm main.wat # make main.wasm
```

```javascript
fetch('main.wasm').then( // load
    response =>
        response.arrayBuffer() // read
).then(bytes =>
       // instantiate
       WebAssembly.instantiate(bytes, imports)
).then(results => {
    // run
    const { main } = results.instance.exports;
    alert( main() );
});
```


## WASM: Quick Boot: Module

Our module holds our assembler. That's what Javascript imports.

```wasm
(module
  (func $main (export "main") (result i32)
      (return (i32.const 42))))
```

Those parentheses? We can write assembler using s-exprs. Paranthesis expressions like lisp.
You can write without parentheses so you have better stack control, but it is hard to read:

```wasm
(module
  (func $main (export "main") (result i32)
   i32.const 42
   return))
```


## WASM: Quick Boot: export

To export a function or value we have to use export. 
- It tells wasm that we'll export that function for javascript. 
- If you don't export a function JS won't see it.

```wasm
(export "main")
```

```wasm
(module
  (func $main (export "main") (result i32)
      (return (i32.const 42))))
```


## WASM: Quick Boot: func

`func` is a function.
- First arg `$main` or `$asmFuncName` is the symbolic name for the assembler
- Follow up with an `(export "main")` to share it with javascript
- Follow up with arguments e.g. `(param $x i32)`
- Follow up with return type if necessary e.g. `(result i32)`

```wasm
(func $asmFuncName 
      (export "nameExportedToJS") 
      (param $x i32) 
      (result i32) 
      ...)
```


## WASM: Quick Boot: func

- The last value on the stack in the function is typically returned
- Constants need a nop or an instruction like return to be returned.

```wasm
(func $asmFuncName (export "nameExportedToJS") (param $x i32) (result i32) ...)
```

```wasm
(module
  (func $funcWithArg (param $x i32) (result i32)
      (get_local $x))
  (func $main (export "main") (result i32)
      (call $funcWithArg (i32.const 42))))
```


## WASM: Quick Boot: call

- To call a function you need to use `call`
- `call` takes a symbol referring to a function and it's args. It returns what the function returns.
- I assume it is call by value.
- You do not get access to the call stack.
- Arguments are type checked!

```wasm
(module
  (func $funcWithArg (param $x i32) (result i32)
      (get_local $x))
  (func $main (export "main") (result i32)
      (call $funcWithArg (i32.const 22))))
```


## WASM: Well that was easy!

We can just eval in the browser right?

- No I use `libwabt.js` to compile the wasm
- You can use a commandline program wat2wabt from the wabt project to compile for you.
- If you want to live compile wasm you need `libwabt.js`


## WASM: So what does it look like:

```wasm
(module
  (func $funcWithArg (param $x i32) (result i32)
      (get_local $x))
  (func $main (export "main") (result i32)
      (call $funcWithArg (i32.const 22))))
```

```wasm
$ wat2wasm -v funcwarg.wat 
0000000: 0061 736d                                 ; WASM_BINARY_MAGIC
0000004: 0100 0000                                 ; WASM_BINARY_VERSION
; section "Type" (1)
0000008: 01                                        ; section code
0000009: 00                                        ; section size (guess)
000000a: 02                                        ; num types
; type 0
000000b: 60                                        ; func
000000c: 01                                        ; num params
000000d: 7f                                        ; i32
000000e: 01                                        ; num results
000000f: 7f                                        ; i32
; type 1
0000010: 60                                        ; func
0000011: 00                                        ; num params
0000012: 01                                        ; num results
0000013: 7f                                        ; i32
0000009: 0a                                        ; FIXUP section size
; section "Function" (3)
0000014: 03                                        ; section code
0000015: 00                                        ; section size (guess)
0000016: 02                                        ; num functions
0000017: 00                                        ; function 0 signature index
0000018: 01                                        ; function 1 signature index
0000015: 03                                        ; FIXUP section size
; section "Export" (7)
0000019: 07                                        ; section code
000001a: 00                                        ; section size (guess)
000001b: 01                                        ; num exports
000001c: 04                                        ; string length
000001d: 6d61 696e                                main  ; export name
0000021: 00                                        ; export kind
0000022: 01                                        ; export func index
000001a: 08                                        ; FIXUP section size
; section "Code" (10)
0000023: 0a                                        ; section code
0000024: 00                                        ; section size (guess)
0000025: 02                                        ; num functions
; function body 0
0000026: 00                                        ; func body size (guess)
0000027: 00                                        ; local decl count
0000028: 20                                        ; local.get
0000029: 00                                        ; local index
000002a: 0b                                        ; end
0000026: 04                                        ; FIXUP func body size
; function body 1
000002b: 00                                        ; func body size (guess)
000002c: 00                                        ; local decl count
000002d: 41                                        ; i32.const
000002e: 16                                        ; i32 literal
000002f: 10                                        ; call
0000030: 00                                        ; function index
0000031: 0b                                        ; end
000002b: 06                                        ; FIXUP func body size
0000024: 0d                                        ; FIXUP section size
```


# Memory Model

WASM keeps a stack hidden from the wasm programmer. This stack
contains values you pushed on it and function call frames that you
can't see.

You cannot see:
- function locations
- function code
- parameter locations
- locals
- local locations


# Memory Model

WASM keeps a stack hidden from the wasm programmer. This stack
contains values you pushed on it and function call frames that you
can't see.

You can:
- allocate as many locals as you want
- define functions
- access some explicitly allocated memory (like a heap)


# WASM Data types

Most operations like add and subtract and division and constants are prefixed by their types:

- i32 (integer 32bit)
- i64 (integer 64bit)
- f32 (floating point 32bit, float, single precision)
- f64 (floating point 64bit, double, double precision)

```wasm
(module
  (func $main (export "main") (result i32)
    (i32.add (i32.const 21) 
             (i32.mul (i32.const 7) (i32.const 3)))))
```


# WASM Instructions / WASM Opcodes

Instructions typically consume 0 or more values off of the stack and
often push a value to the stack.

You cannot access the stack directly.


# {i32,i64,f32,f64}.const

Constant values can represented using const.

```wasm
(module
  (func $main (export "main") (result f64)
    (f64.mul (f64.const 2.0e-9) (f64.const 2.1e10))))
```

```wasm
(module
  (func $main (export "main") (result f32)
    (f32.mul (f32.const 2.0e-9) (f32.const 2.1e10))))
```

```wasm
(module
  (func $main (export "main") (result i64)
    (i64.mul (i64.const 0xFF) (i64.const 0x100000000))))
```

```wasm
(module
  (func $main (export "main") (result i32)
    (i32.mul (i32.const 0xFF) (i32.const 0x10000))))
```


# Arithmetic

Addition, subtraction, multiplication, division, shifts, remainder all
available. Signed and unsigned are available

{i32,i64,f32,f64}.{add,sub,mul,div/div_u/div_s,rem_u/rem_s}

```wasm
(module
  (func $main (export "main") (result f64)
    (f64.add (f64.const 2.0e+1) (f64.const 2.2e+1))))
```

```wasm
(module
  (func $main (export "main") (result i32)
    (i32.mul (i32.const 7) (i32.const 6))))
```

```wasm
(module
  (func $main (export "main") (result i32)
    (i32.div_s (i32.const 1024) (i32.const 24))))
```


# Local Variables

- You can declare local variables with `local`
  - `(local $name type)`
  - `(local $i i32)`
- You can get them with `get_local`
  - `(get_local $i)`
- You can set them with `set_local`
  - `(set_local $i (i32.const 0))`

```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (set_local $i (i32.add (get_local $i) (i32.const 42))) ;; 1
    (get_local $i)))
```


# if statement

- Typically a conditional is kind of painful in assembler.
- In wasm it is pretty simple and it is an expression (it returns a value)

```wasm
(module
  (func $even (param $x i32) (result i32)
    (if (i32.rem_u (get_local $x) (i32.const 2))
        (then (return (i32.const -1024)))
        (else (return (i32.const 1024))))
    (return (i32.const 0)))
  (func $main (export "main") (result i32)
    (call $even (i32.const 42))))
```


# if statement (return a value)

- Typically a conditional is kind of painful in assembler.
- In wasm it is pretty simple and it is an expression (it returns a value)

```wasm
(module
  (func $even (param $x i32) (result i32)
        ;; note we have to declare the result type
        (if (result i32) (i32.rem_u (get_local $x) (i32.const 2))
            (then (i32.const -1024))
            (else (i32.const 1024))))

  (func $main (export "main") (result i32)
    (call $even (i32.const 41)))) ;; 41!
```


# looping with `loop`

- `loop` gives you control flow to loop over a block 
  it has multiple opcodes inside of it.
  
```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (loop
        (set_local $i 
            (i32.add 
                (get_local $i)
                (i32.const 1))))
    (get_local $i)))
```

Wait why didn't it loop? Well we have to jump for it to loop.


# looping with `loop`, `br` 

- `br` is branch, `br 0` means branch to the top of the loop or the end of the current condition.

```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (loop
        (set_local $i 
            (i32.add 
                (get_local $i)
                (i32.const 1)))
        (if (i32.eq (get_local $i) (i32.const 1000))
            (then (return (get_local $i)))) ;; early return
        (br 0))
    (get_local $i)))
```


# looping with `loop`, `br`, `block`, and `br_if`

We don't need to use an if statment, `br_if` is branch if and will
branch for us. It doesn't need an else branch.

```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (block
        (loop
            (set_local $i 
                (i32.add 
                    (get_local $i)
                    (i32.const 1)))
           (br_if 1 (i32.eq (get_local $i) (i32.const 1042)))
           (br 0)))
    (get_local $i)))
```


# looping with `loop`, `br`, `block`, and `br_if`

We don't need to use an if statment, `br_if` is branch if and will
branch for us. It doesn't need an else branch.

```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (block $outer ;; oh is this a label
        (loop ;; this is an infinite loop
            (block $inner ;; oh is this a albel?
                (loop
                    (set_local $i 
                        (i32.add 
                            (get_local $i)
                            (i32.const 1)))
                    (br_if $outer ;; hop to outer loop if
                        (i32.eq (get_local $i) (i32.const 1042)))
                    (br 0)))
           (br 0))) ;; end of $outer loop
    (get_local $i)))
```


# comparisons

- `lt` - less than (f64, f32) `lt_s` and `lt_u` (signed and unsigned) for integers
- `gt` - greater than (f64, f32) `gt_s` and `gt_u` (signed and unsigned) for integers
- `le` - less than or equal (f64, f32) `le_s` and `le_u` (signed and unsigned) for integers
- `ge` - greater than or equal (f64, f32) `ge_s` and `ge_u` (signed and unsigned) for integers
- `eq` - equal 
- `eqz` - equal to zero


# comparisons

- eqz

```wasm
(module
  (func $main (export "main") (result i32)
    (local $i i32) ;; 0'd by default
    (if (result i32) 
        (i32.eqz (get_local $i))
        (then (i32.const 10000))
        (else (i32.const -6)))))
```

- signed greater than

```wasm
(module
  (func $main (export "main") (result i32)
    (if (result i32) 
        (i32.gt_s (i32.const -1) (i32.const 1))
        (then (i32.const 1))
        (else (i32.const -1)))))
```

- unsigned greater than

```wasm
(module
  (func $main (export "main") (result i32)
    (if (result i32) 
        (i32.gt_u (i32.const -1) (i32.const 1))
        (then (i32.const 1))
        (else (i32.const -1)))))
```


# Linear Memory

As stated before you don't have access to the stack memory, where all
your variables and function frames/ frame pointers reside.

But you can declare memory and import it from javascript as well. You
have access to it and its first address is 0. This makes null pointer
checking kinda weird, so watch out.

- `memory` lets you allocate pages of memory
- each wasm module has its own memory

```wasm
(module
    (import "env" "memory" (memory 1)) ;; 1 page of memory 
    (func $main (export "main") (result f64)
        (f64.store (i32.const 0) (f64.const 0.42))
        (f64.load (i32.const 0))))
```


# Arrays

You can treat memory as an array and you can access it from Javascript

```javascript
var memory = new WebAssembly.Memory({initial:1024});
var imports = {
    'env': {
        'memory': memory
    }
};
fetch('sum.wasm').then(
    response =>
        response.arrayBuffer()
).then(bytes =>
       WebAssembly.instantiate(bytes, imports)
).then(results => {
    const {asmSum, asmSum2 } = results.instance.exports;
    let n = 1000;
    let typedArray = new Float64Array(memory.buffer,0,n);
    for (var i = 0 ; i < n; i++) {
        typedArray[i] = i;
    }
    // those values are now in the wasm module's memory.
    ...
});
```


# Browser demo: sum.html

- Let's look at [sum.wat](./sum.wat)
- Let's look at [sum.wasm](./sum.wasm)
  - You can make sum.wasm from the commandline: `wat2wasm sum.wat` 
- Let's look at the JS of [sum.html](./wabt-enabled/sum.html)
  - This example will compile the wasm itself
- Performance wise it is somewhat close to javascript depending on the browser.


# Browser demo: sum.wat

```wasm
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
```


# Browser demo: sum.html

```javascript
var memory = new WebAssembly.Memory({initial:1024});
var imports = {
    'env': {
        'memory': memory
    }
};
fetch('sum.wasm').then(
    response =>
        response.arrayBuffer()
).catch( error =>
         console.log(error)
).then(bytes =>
       WebAssembly.instantiate(bytes, imports)
       //WebAssembly.instantiate(bytes)
).then(results => {
    const {asmSum, asmSum2 } = results.instance.exports;
    const wasmInstance = results.instance;
    memory.grow(10000);
    console.log(wasmInstance);
    console.log(memory);
    function timeit(name,func,n) {
        var t0 = performance.now();
        for (var i = 0; i < n; i++) {
            func();
        }
        var t1 = performance.now();
        console.log("Call to "+name+" took " + (t1 - t0) + " milliseconds.");
    }
    const n = 10000000;
    const p = 0;
    let typedArray = new Float64Array(memory.buffer,p,n*4);
    for (var i = 0 ; i < n; i++) {
        typedArray[i] = i;
    }
    function jsSum(arr,n) {
        var output = 0;
        for (var i = 0 ; i < n; i++) {
            output += arr[i];
        }
        return output;
    };
    const reps = 10;
    const m = n / 2;

    console.log(asmSum(p,n),asmSum(p,n)==jsSum(typedArray,n));
    console.log(asmSum2(p,n),asmSum2(p,n)==jsSum(typedArray,n));
    console.log(jsSum(typedArray,n));
    
    
    timeit("jsSum",function(){ jsSum(typedArray,n) }, reps);
    timeit("asmSum",function(){ asmSum(p,n) }, reps);
    timeit("asmSum2",function(){ asmSum2(p,n) }, reps);

    
    
}).catch(e => console.log(e));
```


# sum.wat performance

- Firefox 76.0.1  
  - `const n = 10000000; const reps = 10;`

```
  Call to jsSum took 186 milliseconds (18.6 ms per rep) sum.html:50:17
  Call to wasmSum took 314 milliseconds (31.4 ms per rep) sum.html:50:17
  Call to wasmSum2 took 126 milliseconds (12.6 ms per rep)
```

- Chromium Version 83.0.4103.61 (Official Build) Built on Ubuntu , running on Ubuntu 18.04 (64-bit)
  - `const n = 10000000; const reps = 10;`

```
  Call to jsSum took 152.4050000000443 milliseconds (15.240500000004431 ms per rep)
  Call to wasmSum took 506.0849999999846 milliseconds (50.60849999999846 ms per rep)
  Call to wasmSum2 took 279.5000000000982 milliseconds (27.950000000009823 ms per rep)
```


# Mandelbrot

- Let's look at [mandel.wat](./wabt-enabled/mandel.wat)
- Let's look at [mandel.wasm](./wabt-enabled/mandel.wasm)
  - You can make mandel.wasm from the commandline: `wat2wasm mandel.wat` 
- Let's look at the JS of [mandel.html](./wabt-enabled/mandel.html)
  - This example will compile the wasm itself
- Performance wise it is somewhat close to javascript depending on the browser.


# Mandelbrot: mandel.wat

```wasm
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
```


# Mandelbrot: mandel.html

```javascript
<!doctype html>
<html>
    <head>
    <title>Mandel.wat</title>
    <script src="libwabt.js"></script>
    <script src="loadWat.js"></script>
    </head>
    <body style="background: white;">
    <div width="100%" height="100vh">
        <canvas id="canvas1" width="100%" height="100%">
        </canvas>
        <canvas id="canvas2" width="100%" height="100%">
        </canvas>
        <canvas id="canvas3" width="100%" height="100%">
        </canvas>
        <canvas id="canvas4" width="100%" height="100%">
        </canvas>
<script>
...
</script>
</body>
</html>
```


# Mandelbrot: mandel.html JS

```javascript
var wabt = WabtModule();
var memory = new WebAssembly.Memory({initial:10000});
var imports = {
    'env': {
        'memory': memory
    }
};
var l0 = performance.now();
loadWatURL(wabt,'mandel.wat',imports,'mandel.wat').then(results => {
    var l1 = performance.now();
    console.log("Retrieving, loading, assembling took " + (l1 - l0) + " milliseconds.");

    const { mandel, drawMandel } = results.instance.exports;
    const asmMandel = mandel;
    const wasmInstance = results.instance;
    //memory.grow(10000);
    console.log(wasmInstance);
    console.log(memory);
    const p = 0;
    let RES = 600;
    let typedArray = new Uint8Array(memory.buffer,p,RES*RES*4);
    function clearBuffer(buf) {
        for (var i = 0 ; i < buf.length; i++) {
            buf[i] = 0;
        }
    }
    function timeit(name,func,n) {
        var t0 = performance.now();
        for (var i = 0; i < n; i++) {
            func(i);
        }
        var t1 = performance.now();
        console.log("Call to "+name+" took " + (t1 - t0) + " milliseconds.");
    }
    // https://rosettacode.org/wiki/Mandelbrot_set#PPM_non_interactive
    // GNU FDL Rosetta Code
    function jsMandel(cx,cy,maxiter) {
        var i = 0;
        var zx = 0;
        var zy = 0;
        var zx2 = 0;
        var zy2 = 0;
        for (i = 0 ; i < maxiter && ((zx2 + zy2) < 4.0); i++) {
            zy = cy + 2.0 * zx * zy;
            zx = cx + zx2 - zy2;
            zx2 = zx * zx;
            zy2 = zy * zy;
        }
        return i;
    };
    const reps = 100;
    const iters = 100000;
    console.log(jsMandel(0,0,iters) == asmMandel(0,0,iters));
    console.log(jsMandel(2,1,iters) == asmMandel(2,1,iters));
    timeit("jsMandel",function(i){ jsMandel(1.0/i,1.0/i,iters) }, reps);
    timeit("asmMandel",function(i){ asmMandel(1.0/i,1.0/i,iters) }, reps);

    let drawMandelPixels = function(myMandel, canvasID) {
        var canvas = document.getElementById(canvasID);
        var canvasWidth  = RES;
        var canvasHeight = RES;
        canvas.width = RES;
        canvas.height = RES;
        var ctx = canvas.getContext('2d');
        var imageData = ctx.getImageData(0, 0, canvasWidth, canvasHeight);
        var data = imageData.data;
        var buf = new ArrayBuffer(imageData.data.length);
        var buf8 = new Uint8ClampedArray(buf);
        var data32 = new Uint32Array(buf);
        var citers = 256;
        for (var y = 0; y < canvasHeight; ++y) {
            for (var x = 0; x < canvasWidth; ++x) {
                var index = (y * canvasWidth + x) * 4;
                var value = myMandel(2*x/(1.0*canvasWidth) - 1.5,2*y/(1.0*canvasHeight) - 1.0,citers);
                data[index] = data[index+1] = data[index+2] = value & 0xFF;
                data[index+3] = 255;
            }
        }
        // imageData.data.set(buf8);
        ctx.putImageData(imageData, 0, 0);
        canvas.style.height = "50vh";
        console.log("Done");
        // make sure it big enough
    };
    timeit("jsMandel",  () => drawMandelPixels(jsMandel, 'canvas1'),1);
    timeit("asmMandel", () => drawMandelPixels(asmMandel,'canvas2'),1);
    let drawMandelBuffer = function(myMandelBuf, canvasID) {
        var canvas = document.getElementById(canvasID);
        var canvasWidth  = RES;
        var canvasHeight = RES;
        canvas.width = RES;
        canvas.height = RES;
        var ctx = canvas.getContext('2d');
        var imageData = ctx.getImageData(0, 0, canvasWidth, canvasHeight);
        var buf = typedArray;
        var buf8 = new Uint8ClampedArray(buf);
        var data32 = new Uint32Array(buf);
        var citers = 256;
        console.log(buf, canvasWidth, canvasHeight, 2.0, 1.5, 2.0, 1.0, citers);
        myMandelBuf(buf, canvasWidth, canvasHeight, 2.0, 1.5, 2.0, 1.0, citers);
        imageData.data.set(buf);
        ctx.putImageData(imageData, 0, 0);
        canvas.style.height = "50vh";
        console.log("Done");
        // make sure it big enough
    };
    let jsMandelBuf = function(data, w, h, xscale, xoff, yscale, yoff, iters) {
        for (var y = 0; y < h; ++y) {
            for (var x = 0; x < w; ++x) {
                var index = (y * w + x) * 4;
                var value = jsMandel(xscale*x/(1.0*w) - xoff,yscale*y/(1.0*h) - yoff,iters);
                data[index] = data[index+1] = data[index+2] = value & 0xFF;
                data[index+3] = 255;
            }
        }
        return 1;
    }
    let wasmMandelBuf = function(data, w, h, xscale, xoff, yscale, yoff, iters) {
        return drawMandel(data.byteOffset, w, h, xscale, xoff, yscale, yoff, iters);
    }
    clearBuffer(typedArray);
    timeit("jsMandelBuf",    () => drawMandelBuffer(jsMandelBuf  , 'canvas3'),1);
    clearBuffer(typedArray);
    timeit("wasmMandelBuf",  () => drawMandelBuffer(wasmMandelBuf, 'canvas4'),1);
    console.log(typedArray);
}).catch(e => console.log(e));
```


# Mandel.wat performance

- Firefox 76.0.1  

```
Call to jsMandel took 37 milliseconds. 
Call to asmMandel took 39 milliseconds. 

Call to jsMandel took 151 milliseconds. 
Call to asmMandel took 154 milliseconds.
Call to jsMandelBuf took 148 milliseconds.
Call to wasmMandelBuf took 161 milliseconds.
```

- Chromium Version 83.0.4103.61 (Official Build) Built on Ubuntu , running on Ubuntu 18.04 (64-bit)

```
Call to jsMandel took 41.32499999968786 milliseconds.
mandel.html:51 Call to asmMandel took 63.479999999799475 milliseconds.

mandel.html:51 Call to jsMandel took 155.8700000000499 milliseconds.
mandel.html:51 Call to asmMandel took 259.8849999999402 milliseconds.
mandel.html:51 Call to jsMandelBuf took 162.40500000003522 milliseconds.
mandel.html:51 Call to wasmMandelBuf took 237.5649999999041 milliseconds.
```


# Performance comments

- Most performance is probably in productivity of reusing existing programs
- Most performance is likely from faster load times


# Where to look further

- llvm
- empscripten
- rust
- go


# Conclusions

- Should you use WASM?
  - Probably not
- Is WASM useful?
  - Yes you can compile other languages in such a way that javascript in the browser can use that code!
  - For integer types it is very useful  
- Does it perform well?
  - Yes, but not stellar
- Do people use WASM like you demonstrated?
  - No. I just wanted to learn basic WASM.
  - Most people will generate WASM and use that.


# Resources

- Justin Lin, WebAssembly MVP Tutorial https://openhome.cc/eGossip/WebAssembly/
- Web Assembly By Example https://wasmbyexample.dev/
- WebAssembly at MDN https://developer.mozilla.org/en-US/docs/WebAssembly
- WABT Project https://github.com/webassembly/wabt
- Colin Eberhardt, 2018-04-26, https://blog.scottlogic.com/2018/04/26/webassembly-by-hand.html
- WebAssembly Opcodes https://pengowray.github.io/wasm-ops/


# Demo

You can write some live assembly here if you want. Knock yourself out.
You could just use this: https://webassembly.github.io/wabt/demo/wat2wasm/
<div>
<div class="wasm">
<textarea cols=80 rows=6>
(module
  (func $main (export "main") (result i32)
      (return (i32.const 42))))
</textarea>
</div>
</div>

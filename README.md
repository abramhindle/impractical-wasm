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

# Arrays

# Browser demo


# Performance comments

- Most performance is probably in productivity of reusing existing programs
- Most performance is likely from faster load times


# Where to look further
- llvm
- empscripten
- rust
- go


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

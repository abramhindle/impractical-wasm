/*
 * Copyright 2016 WebAssembly Community Group participants
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/* Depends on WabtModule from libwabt.js */

var FEATURES = [
  'exceptions',
  'mutable_globals',
  'sat_float_to_int',
  'sign_extension',
  'simd',
  'threads',
  'multi_value',
  'tail_call',
  'bulk_memory',
  'reference_types',
];

function wasmMemory(initial) {
    if (!initial) {
        initial = 1024;
    }
    var memory = new WebAssembly.Memory({initial:initial});
    var default_imports = {
        'env': {
            'memory': memory
        }
    };
    return default_imports;         
}
function loadWatString(wabt,text,imports,filename) {
    // wat to wasm in memory
    var module = wabt.parseWat(filename,text,FEATURES);
    module.resolveNames();
    module.validate(FEATURES);
    var binaryOutput = module.toBinary({log: true, write_debug_names:true});
    binaryBuffer = binaryOutput.buffer;
    let wasm = WebAssembly.instantiate(binaryBuffer, imports)
    return wasm;
}
function loadWatURL(wabt,watURL,imports,filename) {
    // Copyright 2016 WebAssembly Community Group participants
    // stolen from https://webassembly.github.io/wabt/demo/wat2wasm/
    if (!imports) {
        imports = default_imports();
    }
    if (!filename) {
        filename = "test.wat";
    }
    return fetch(watURL).then(
        response =>
            response.text()
    ).then(text => {        
        // wat to wasm in memory
        return loadWatString(wabt,text,imports,filename);
    });
}

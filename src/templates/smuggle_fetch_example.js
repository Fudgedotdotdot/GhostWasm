function runNimWasm(w){for(i of WebAssembly.Module.exports(w)){n=i.name;if(n[0]==';'){new Function('m',n)(w);break}}}

function myFunction() {
    fetch("/{{o.name}}.wasm")
    .then(resp => resp.arrayBuffer())
    .then(buffer => new Uint8Array(buffer))
    .then(wasmBytes => WebAssembly.compile(wasmBytes))
    .then(runNimWasm);
}



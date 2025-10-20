# GhostWasm
![WSL](https://img.shields.io/badge/WSL-2-blue)<br>
![Nim](https://img.shields.io/badge/Nim-yellow)


GhostWasm embeds payloads in HTML and SVG files and delivers them as WebAssembly rather than JavaScript. This avoids detections for traditional JavaScript-based smuggling code snippets. 

It can generate WebAssembly payloads for : 
- File smuggling - delivers arbitrary files
- Redirection - performs client side redirection
- HTML pages - injects HTML content

The generated WebAssembly code is inserted into templates that you can develop and customize depending on the pretext of the day. 


Anti‑bot checks are enabled by default. They are basic, but help prevent payloads from triggering during automated bot scans. 



## Requirements
Tested on WSL2 (Debian GNU/Linux 12 (bookworm)). 

Install `clang` and `ldd` (not included in clang's package): 
```bash
sudo apt-get install clang
sudo apt-get install lld
```

## Building

```bash
nimble build --verbose
```

You can specify another template directory at compile time. The directory has to be specifed as an absolute path.
```bash
nimble build --verbose -d:customTemplates -d:templateDir:/home/fudge/tools/ttt
```

The custom template directory needs to be structured like this: 
```
~/tools/ttt
❯ tree
.
└── templates
    ├── html_aes_example.css
    ├── html_aes_example.html
    ├── html_aes_example.js
```

Macros are executed at compile time to get around the static file path requirement by the templating engine **nimja**. You can see the generated code by building with this command: 
```bash
nimble build --verbose -d:debug
```

In debug builds, compilation details from the WASM builder are also displayed.
```
Compiling WASM builder...
[WASM COMPILE OUTPUT] <output here>
```

## Creating templates

The template filenames need to follow a specific format. 

`<type>_<template_name>.extension`

For example, these templates are used for the `html` option and can all be templated. 
```
html_aes_example.html
html_aes_example.css
html_aes_example.js
```

The template `smuggle_xor_example.html` is for the `smuggle` option and is the only file that will be templated. 


The following extensions are supported:
- html
- css
- js
- svg
- wasm (raw bytes)



### Templating options


This object is passed as an argument to the templating function: 
```Nim
type
  WasmObject* = object
    signature*: string
    wasmBytes*: seq[byte]
    aesKey*: array[32, byte]
    aesIv*: array[16, byte]
    xorKey*: string
    name*: string
```
You can use all of the attributes of the object like so:  `{{o.wasmBytes}}` or `{{o.name}}`.

These helper functions are callable from your templates, in addition to builtin Nim functions. 
- rot13
- raw_bytes
- b64
- compress
- xor_encrypt
- aes_encrypt

They can be chained together:  `{{b64(aes_encrypt(compress(o.wasmBytes), o.aesKey, o.aesIv))}}`.

See the available templates for examples on how to use them, and go read the [nimja](https://github.com/enthus1ast/nimja) documentation on how to do even more. 



## Usage
Read the help menu with `./ghostwasm -h`



#### Example usage
```
❯ ./ghostwasm smuggle -n "test.txt" -f ~/tools/ghostwasm/examples/smuggle_file.txt -p ~/tools  -o mypayload
 _____ _               _   _    _
|  __ \ |             | | | |  | |
| |  \/ |__   ___  ___| |_| |  | | __ _ ___ _ __ ___
| | __| '_ \ / _ \/ __| __| |/\| |/ _` / __| '_ ` _ \
| |_\ \ | | | (_) \__ \ |_\  /\  / (_| \__ \ | | | | |
 \____/_| |_|\___/|___/\__|\/  \/ \__,_|___/_| |_| |_|

                         Stealth HTML and SVG smuggler
                         By: Fudge...


Listing templates:
== [0] smuggle_xor_example            (extensions: html)
== [1] smuggle_fetch_example          (extensions: html, js, wasm)
Select the template: 1
Compiling WASM builder...
Writing files:
== /home/fudge/tools/mypayload.html
== /home/fudge/tools/mypayload.js
== /home/fudge/tools/mypayload.wasm
Encryption keys (Base64):
== AES KEY:  QKzEwEBLFJKTzwXfg9ClROMHnTaE92fxzyO5xWDkMuU=
== AES IV:   EYO5ctbl1kwb68J+kbxNOA==
== XOR KEY:  MT9iNnJwLChaZV8nIjM1Ww==
```
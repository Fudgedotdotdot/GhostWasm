import strformat, strutils
import os, osproc
import std/sysrand, random
import std/base64

import constants_types


proc gen_aes_key*(): array[32, byte] = 
  var k = urandom(32)
  for i, x in k:
    result[i] = x
  
proc gen_aes_iv*(): array[16, byte] = 
  var k = urandom(16)
  for i, x in k:
    result[i] = x


proc gen_xorkey*(l: int): string = 
    result = newString(l)
    randomize()
    for i in 0..<l:
        result[i] = sample(Letters + Digits + PunctuationChars)


proc print_encryption_keys*(wasm: WasmObject) = 
  echo "Encryption keys (Base64):"
  echo &"== AES KEY:  {encode(wasm.aesKey)}"
  echo &"== AES IV:   {encode(wasm.aesIv)}"
  echo &"== XOR KEY:  {encode(wasm.xorKey)}"

proc read_file_bytes*(f: string): seq[byte] = 
  var fhandle = open(f)
  defer: fhandle.close()
  var fsize = getFileSize(fhandle)
  var fbytes: seq[byte] = newSeq[byte](fsize)
  var fread = readBytes(fhandle, fbytes, 0, fsize)
  if fread == fsize:
    return fbytes
  raise newException(IOError, fmt"File was not read correctly: fsize: {fsize} != fread: {fread}") 


proc get_extensions(t: TemplateFiles): seq[string] = 
    var exts: seq[string]
    for x, y in t.fieldPairs: 
      if y.len != 0 and x != "name": exts.add(x)
    return exts


proc pprint_templates*(templates: seq[TemplateFiles]) = 
  for i, t in templates:
    var exts = get_extensions(t)
    echo fmt"""== [{i}] {t.name:<30} (extensions: {exts.join(", ")})"""


proc write_templates*(t: TemplateContents, template_name, output_name, output_path: string) = 
  echo "Writing files:"
  for exttype, content in t.fieldPairs:
    var extstr = exttype 
    if content.len != 0:
      var filename: string
      if output_name.len > 0: filename = output_name else: filename = &"ghostwasm_{template_name}"
      var output_file = &"{output_path}/{filename}.{extstr}"
      echo &"== {output_file}"
      writeFile(output_file, content)


proc compile_wasm*(compile_cmd: string) = 
  var res = execCmdEx(compile_cmd, options = {poStdErrToStdOut}, workingDir = SCRIPT_BASE_DIR / "builder")
  when defined(debug):
    for x in res.output.splitLines: echo "[WASM COMPILE OUTPUT] " & x

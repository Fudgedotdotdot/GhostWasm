import times
import macros
import os, sequtils
import strutils
import tables
import std/base64

import constants_types

import nimja 
import zippy/deflate
import nimcrypto



proc rot13(str: string): string =
  for ch in str:
    case toLowerAscii(ch)
    of 'a'..'m': result.add chr(ord(ch) + 13)
    of 'n'..'z': result.add chr(ord(ch) - 13)
    else:
      result.add ch


proc raw_bytes(data: seq[byte]): string = 
  result = newString(data.len)
  for i, c in data:
    result[i] = cast[char](c)


proc b64[T: byte or char](data: openArray[T], safe: bool = false): string =
  encode(data, safe)


proc compress[T: byte or char](b: openArray[T]): string = 
  if b.len == 0: return ""
  deflate(result, cast[ptr UncheckedArray[byte]](b[0].addr), b.len, 5)


proc xor_encrypt*[T: byte or char](data: openArray[T], key: string): string = 
  result = newString(data.len)
  if key.len == 0: return ""
  for i, c in data:
    result[i] = char(ord(c) xor ord(key[i mod key.len]))
    

proc aes_encrypt[T: byte or char](data: openArray[T], aesKey: array[32, byte], aesIv: array[16, byte]): seq[byte] = 
  var ectx: CTR[aes256]
  var key: array[aes256.sizeKey, byte]
  var iv: array[aes256.sizeBlock, byte]
  var plainText = newSeq[byte](len(data))
  var encText = newSeq[byte](len(data))

  copyMem(addr plainText[0], addr data[0], len(data))
  copyMem(addr key[0], addr aesKey[0], len(aesKey))
  copyMem(addr iv[0], addr aesIv[0], len(aesIv))

  ectx.init(key, iv)
  ectx.encrypt(plainText, encText)
  ectx.clear()
  return encText


### ugly macro magic - avert your eyes ##

macro collectTemplates*(dir: static[string]): seq[TemplateFiles] =
  var templates: seq[TemplateFiles]

  proc findIdx(tseq: seq[TemplateFiles], name: string): int {.compiletime.} = 
    for i, t in tseq:
      if t.name == name:
        return i
    return -1

  for p in toSeq(walkDir(dir)):
    if p.kind != pcFile: continue
    let base = p.path.splitFile.name
    var ext  = p.path.splitFile.ext
    ext.removePrefix('.')

    var idx = findIdx(templates, base)
    if idx >= 0:
      case ext: 
        of "html": templates[idx].html = p.path
        of "css": templates[idx].css = p.path
        of "js": templates[idx].js = p.path
        of "svg": templates[idx].svg = p.path
        of "wasm": templates[idx].wasm = p.path
        else: discard
    else: 
      templates.add((name: base, html: "", css: "", js: "", svg: "", wasm: ""))
      var idx = findIdx(templates, base)
      if idx == -1: continue
      case ext: 
        of "html": templates[idx].html = p.path
        of "css": templates[idx].css = p.path
        of "js": templates[idx].js = p.path
        of "svg": templates[idx].svg = p.path
        of "wasm": templates[idx].wasm = p.path
        else: discard

  let seqLit = newLit(templates)
  return seqLit

const CONST_TEMPLATES*: seq[TemplateFiles] = collectTemplates(CONST_TEMPLATE_PATH)

macro generate_render_functions(): untyped =
  let render_fncs = newStmtList()

  for templ in CONST_TEMPLATES:
      var tfunctionName = ident(FUNC_PREFIX & templ.name)

      let body = newStmtList()
      let calls = newStmtList()

      let varSection = newNimNode(nnkVarSection).add(
          newIdentDefs(ident("t"), ident("TemplateContents"), newEmptyNode())
      )
      body.add(varSection)


      if templ.html.len != 0:
        var tpathLit = newLit(templ.html)
        let htmlCall = newAssignment(
            newDotExpr(ident("t"), ident("html")),
            newCall(ident("tmplf"), tpathLit)
            #newCall(ident("tmplf"), tpathLit, nnkExprEqExpr.newTree(ident("basedir"), newLit(SCRIPT_BASE_DIR)))
        )
        calls.add(htmlCall)

      if templ.css.len != 0:
        var tpathLit = newLit(templ.css)
        let cssCall = newAssignment(
            newDotExpr(ident("t"), ident("css")),
            #newCall(ident("tmplf"), tpathLit, nnkExprEqExpr.newTree(ident("basedir"), newLit(SCRIPT_BASE_DIR)))
            newCall(ident("tmplf"), tpathLit)
        )
        calls.add(cssCall)

      if templ.js.len != 0:
        var tpathLit = newLit(templ.js)
        let jsCall = newAssignment(
            newDotExpr(ident("t"), ident("js")),
            #newCall(ident("tmplf"), tpathLit, nnkExprEqExpr.newTree(ident("basedir"), newLit(SCRIPT_BASE_DIR)))
            newCall(ident("tmplf"), tpathLit)
        )
        calls.add(jsCall)

      if templ.svg.len != 0:
        var tpathLit = newLit(templ.svg)
        let svgCall = newAssignment(
            newDotExpr(ident("t"), ident("svg")),
            #newCall(ident("tmplf"), tpathLit, nnkExprEqExpr.newTree(ident("basedir"), newLit(SCRIPT_BASE_DIR)))
            newCall(ident("tmplf"), tpathLit)
        )
        calls.add(svgCall)

      if templ.wasm.len != 0:
        var tpathLit = newLit(templ.wasm)
        let wasmCall = newAssignment(
            newDotExpr(ident("t"), ident("wasm")),
            #newCall(ident("tmplf"), tpathLit, nnkExprEqExpr.newTree(ident("basedir"), newLit(SCRIPT_BASE_DIR)))
            newCall(ident("tmplf"), tpathLit)
        )
        calls.add(wasmCall)

      body.add(calls, nnkReturnStmt.newTree(ident("t")))

      let paramsArray: array[2, NimNode] = [
          ident("TemplateContents"),
          newIdentDefs(ident("o"), ident("WasmObject"))
      ]
      let callProc = newProc(
          tfunctionName, 
          paramsArray,
          body
      )

      render_fncs.add(callProc)

  when defined(debug):
    echo "==== Generated functions ===="
    echo render_fncs.repr
  return render_fncs


macro generate_dispatch_func(): untyped = 
  var dispatch_func = newStmtList()
  let dispatchIdent = ident("dispatch")
  dispatch_func.add quote do:
      var `dispatchIdent`: Table[string, proc(o: WasmObject): TemplateContents]

  for templ in CONST_TEMPLATES:
    var tfunctionName = ident(FUNC_PREFIX & templ.name)
    let tfunctionStr = templ.name
    dispatch_func.add quote do:
        `dispatchIdent`[`tfunctionStr`] = `tfunctionName`

  when defined(debug):
    echo "==== Generated dispatch table ===="
    echo dispatch_func.repr
  return dispatch_func


generate_render_functions()
generate_dispatch_func()

proc renderFiles*(t: WasmObject, template_name: string): TemplateContents =
  return dispatch[template_name](t) # dispatch is the dispatcher function generated by the generate_dispatch_func() macro
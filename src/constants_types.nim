import os


const SCRIPT_BASE_DIR* = currentSourcePath().parentDir()
when defined(customTemplates):
  const templateDir {.strdefine.}: string = ""
  const CONST_TEMPLATE_PATH* = templateDir / "templates"
else:
  const CONST_TEMPLATE_PATH* = SCRIPT_BASE_DIR / "templates"


const FUNC_PREFIX* = "ghostwasm_render_"

type
  WasmObject* = object
    signature*: string
    wasmBytes*: seq[byte]
    aesKey*: array[32, byte]
    aesIv*: array[16, byte]
    xorKey*: string
    name*: string



type TemplateContents* = object
  html*, css*, js*, svg*, wasm*: string

type 
  TemplateFiles* = tuple[name, html, css, js, svg, wasm: string]


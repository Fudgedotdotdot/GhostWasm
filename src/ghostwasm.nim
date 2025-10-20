import functions
import cligen

proc show_banner() =
  proc grey(s: string): string    = "\e[90m" & s & "\e[0m"
  proc magenta2(s: string): string = "\e[38;5;99m" & s & "\e[0m"
  proc cyan2(s: string): string = "\e[38;5;81m" & s & "\e[0m"

  echo magenta2(r" _____ _               _   _    _                     ")
  echo magenta2(r"|  __ \ |             | | | |  | |                    ")
  echo magenta2(r"| |  \/ |__   ___  ___| |_| |  | | __ _ ___ _ __ ___  ")
  echo magenta2(r"| | __| '_ \ / _ \/ __| __| |/\| |/ _` / __| '_ ` _ \ ")
  echo magenta2(r"| |_\ \ | | | (_) \__ \ |_\  /\  / (_| \__ \ | | | | |")
  echo magenta2(r" \____/_| |_|\___/|___/\__|\/  \/ \__,_|___/_| |_| |_|")
  echo grey("                                                           ")
  echo cyan2("                         Stealth HTML and SVG smuggler")
  echo cyan2("                         By: Fudge...")
  echo "\n"


if isMainModule:
  show_banner()
  dispatchMulti(
    [smuggle, 
    doc="Smuggle file", 
    help={
      "filepath": "Path to the file to smuggle", 
      "filename": "Download filename",
      "output_name": "Sets the output name (defaults to \"ghostwasm_<template name>\")",
      "output_path": "Sets the output directory (defaults to current working directory)",
      "antibot_disable": "Disable antibot checks"
      },
      short = {
        "filepath": 'f',
        "filename": 'n',
        "output_path": 'p',
        "output_name": 'o',
        "antibot_disable": 'a'
    }],
    [redirect, 
    doc="Redirect user", 
    help={
      "url": "URL to redirect to", 
      "output_name": "Sets the output name (defaults to \"ghostwasm_<template name>\")",
      "output_path": "Sets the output directory (defaults to current working directory)",
      "antibot_disable": "Disable antibot checks"
      },
      short = {
        "url": 'u',
        "output_path": 'p',
        "output_name": 'o',
        "antibot_disable": 'a'
    }],
    [html, 
    doc="Writes document to page", 
    help={
      "filepath": "Path to the HTML file", 
      "output_name": "Sets the output name (defaults to \"ghostwasm_<template name>\")",
      "output_path": "Sets the output directory (defaults to current working directory)",
      "antibot_disable": "Disable antibot checks"
      },
      short = {
        "filepath": 'f',
        "output_path": 'p',
        "output_name": 'o',
        "antibot_disable": 'a'
    }],
  )
parse = require 'css-parse'
marked = require 'marked'
hljs = require 'highlight.js'
ent = require 'ent'
fs = require 'fs'
read = fs.readFileSync


css2docco = (file) ->
  marked.setOptions
    sanitize: false
    gfm: true

  css = read file, 'utf8'
  json = parse css

  #console.log JSON.stringify(json, null, 2)

  result = ''
  for rule, i in json.stylesheet.rules
    if rule.type is 'comment'
      md = marked rule.comment
      
      html = ent.decode(md)
      codeStartToken = '<pre><code>'
      codeEndToken = '</code></pre>'
      codeStart = html.indexOf codeStartToken
      codeEnd = html.indexOf codeEndToken
      hasCode = codeStart isnt -1
      if hasCode
        codeStart += codeStartToken.length
        code = html.substring codeStart, codeEnd

        # pre code markdown
        result += md.substr 0, codeStart
        
        # code example
        result += hljs.highlightAuto(code).value
        result += codeEndToken

        # component
        result += code

  return result

docco = css2docco 'styles.css'

html = '<link href="code.css" rel="stylesheet">'
html += '<link href="styles.css" rel="stylesheet">'
html += docco

fs.writeFileSync 'foo.html', html
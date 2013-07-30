parse = require 'css-parse'
marked = require 'marked'
hljs = require 'highlight.js'
ent = require 'ent'
fs = require 'fs'
read = fs.readFileSync

css = read('styles.css', 'utf8');
json = parse css

console.log JSON.stringify(json, null, 2)

marked.setOptions
  sanitize: false
  gfm: true

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
      console.log "Code #{codeStart}-#{codeEnd} " + code

      content = '<link href="code.css" rel="stylesheet">'
      content += '<link href="styles.css" rel="stylesheet">'
      value = hljs.highlightAuto(md).value
      console.log "VALUE #{value}"

      # pre code markdown
      content += md.substr 0, codeStart
      
      # code example
      content += hljs.highlightAuto(code).value
      content += codeEndToken

      # component
      content += code

      fs.writeFileSync 'foo.html', content
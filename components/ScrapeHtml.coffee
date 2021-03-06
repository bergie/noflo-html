noflo = require "noflo"
cheerio = require "cheerio"

# @runtime noflo-nodejs

decode = (str) ->
  return str unless str.indexOf "&" >= 0
  return str.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&")

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Extract contents from HTML based on CSS selectors'

  c.inPorts.add 'in',
    datatype: 'string'
    description: 'HTML to scrape from'
  c.inPorts.add 'textselector',
    datatype: 'string'
    description: 'CSS selector to use'
  c.inPorts.add 'ignoreselector',
    datatype: 'string'

  c.ignoreSelectors = []

  c.cleanUp = (callback) ->
    c.ignoreSelectors = []
    callback()

  c.outPorts.add 'out',
    datatype: 'string'

  c.process (input, output) ->
    while input.hasData 'ignoreselector'
      c.ignoreSelectors.push input.getData 'ignoreselector'

    return unless input.hasData 'in', 'textselector'
    [data, textselector] = input.getData 'in', 'textselector'
    $ = cheerio.load data
    $(ignore).remove() for ignore in c.ignoreSelectors
    $(textselector).each (i,e) ->
      o = $(e)
      id = o.attr "id"
      if id?
        output.send
          out: new noflo.IP 'openBracket', id
      output.send
        out: decode o.text()
      if id?
        output.send
          out: new noflo.IP 'closeBracket', id
    output.done()

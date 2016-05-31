# This module deals with text blocks - blocks of texts that can be optionally
# transformed.

{convertNewlinesToHTML} = require './htmlutil'

# A list of HTML blocks with potentially differing transformations.
class BlockList
  constructor: ->
    @blocks = []

  append: (html, newlines=true, smileys=true) ->
    # If we're merging to a block with the same options, append.
    if @blocks.length > 0
      lastBlock = @blocks[@blocks.length-1]
      if lastBlock.newlines is newlines and lastBlock.smileys is smileys
        lastBlock.html += html
        return lastBlock
    @blocks.push(new Block(html, newlines, smileys))

  appendHTML: (html) ->
    @append(html)

  appendRawHTML: (html) ->
    @append(html, false, false)

  transform: (parser) ->
    if @firstBlock is null
      return ""
    html = []
    for block in @blocks
      html.push(block.toHTML(parser))
    html.join('')

class Block
  constructor: (@html, @newlines = true, @smileys = true) ->

  toHTML: (parser) ->
    text = @html
    if @newlines
      text = convertNewlinesToHTML(text)
    if @smileys
      text = parser.replaceSmileys(text)
    text

module.exports = BlockList
BlockList.Block = Block

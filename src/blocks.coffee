# This module deals with text blocks - blocks of texts that can be optionally
# transformed.

{convertNewlinesToHTML} = require './htmlutil'

# A list of HTML blocks with potentially differing transformations.
class BlockList
  constructor: ->
    @firstBlock = null
    @lastBlock = null

  appendBlock: (block) ->
    if block isnt null
      if @firstBlock is null
        @firstBlock = block
        @lastBlock = block
      else
        @lastBlock.append block
        @lastBlock = block

  append: (html, newlines=true, smileys=true) ->
    @appendBlock(new Block(html, newlines, smileys))

  appendHTML: (html) ->
    @append(html)

  appendRawHTML: (html) ->
    @append(html, false, false)

  transform: (parser) ->
    if @firstBlock is null
      return ""
    @firstBlock.merge()
    # We need to go through the blocks anyway, so:
    html = []
    block = @firstBlock
    loop
      html.push(block.toHTML(parser))
      if block.next?
        block = block.next
      else
        @lastBlock = block
        break
    html.join('')

class Block
  constructor: (@html, @newlines = true, @smileys = true) ->

  append: (block) ->
    if block isnt null
      block.prev = this
      @next = block

  # Merge matching blocks together. If a block has identical transforms, it will
  # be merged into a new, single block.
  merge: ->
    current = this
    next = current.next
    while next?
      if current.newlines is next.newlines and current.smileys is next.smileys
        current.html += next.html
        # Remove the merged block from the list
        current.next = next.next
        if next.next?
          next.next.prev = current
      next = next.next

  toHTML: (parser) ->
    text = @html
    if @newlines
      text = convertNewlinesToHTML(text)
    if @smileys
      text = parser.replaceSmileys(text)
    text

module.exports = BlockList
BlockList.Block = Block

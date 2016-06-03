# This module deals with text blocks - blocks of texts that can be optionally
# transformed.

{convertNewlinesToHTML} = require './htmlutil'

###
A list of HTML blocks with potentially differing transformations.
###
class BlockList
  ###
  Creates a new BlockList.
  ###
  constructor: ->
    @blocks = []

  ###
  Appends HTML to the list.

  @param [String] html
    the HTML to append
  @param [Boolean] newlines
    whether newlines should be converted to HTML using {~convertNewlinesToHTML}
  @param [Boolean] smileys
    whether smileys should be converted to some other form
  ###
  append: (html, newlines=true, smileys=true) ->
    # If we're appending to a block with the same options, just add the HTML
    # onto the existing block.
    if @blocks.length > 0
      lastBlock = @blocks[@blocks.length-1]
      if lastBlock.newlines is newlines and lastBlock.smileys is smileys
        lastBlock.html += html
        return lastBlock
    @blocks.push(new Block(html, newlines, smileys))

  ###
  Appends HTML that has newlines escaped and smileys replaced.

  @param [String] html
    the HTML to append
  ###
  appendHTML: (html) ->
    @append(html)

  ###
  Appends HTML that is left as-is, with no new lines replaced and no smileys
  replaced.

  @param [String] html
    the HTML to append
  ###
  appendRawHTML: (html) ->
    @append(html, false, false)

  ###
  Converts every that has been pended to the BlockList to its final HTML form.

  @param [BBCodeParser] parser
    the BBCodeParser to use for translating smileys, or `null` to skip that step
  @return [String]
    the translated HTML
  ###
  toHTML: (parser) ->
    if @firstBlock is null
      return ""
    html = []
    for block in @blocks
      html.push(block.toHTML(parser))
    html.join('')

###
Internal representation of a single block within the {BlockList}. Generally
speaking there should be no reason to directly use this class. Instead use the
{BlockList#append} method.
@private
###
class Block
  ###
  Constructs a new block.

  @param [String] html
    the HTML to append
  @param [Boolean] newlines
    whether newlines should be converted to HTML using {~convertNewlinesToHTML}
  @param [Boolean] smileys
    whether smileys should be converted to some other form
  @param [Boolean] paragraph
    in the future (not yet) whether or not the text should be surrounded by a
    paragraph or not (intended for use inside an `<li>` or possibly table cells
    or other occassions where always surrounding with a paragraphs doesn't make
    sense). The feature is not implemented yet and this flag is ignored.
  ###
  constructor: (@html, @newlines = true, @smileys = true, @paragraph = true) ->

  ###
  Execute the active translatings, returning the result.

  @param [BBCodeParser] parser
    the BBCodeParser to use for translating smileys, or `null` to skip that step
  @return [String]
    the translated HTML
  ###
  toHTML: (parser) ->
    text = @html
    if @newlines
      text = convertNewlinesToHTML(text)
    if @smileys and parser?
      text = parser.replaceSmileys(text)
    text

module.exports = BlockList
BlockList.Block = Block

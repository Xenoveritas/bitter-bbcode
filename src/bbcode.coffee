###
# BBCode

Module for parsing BBCode. BBCode is translating into a pseudo-DOM which can
then be translated into "blocks" and then into HTML.

This module is extensible, allowing "new" BBCode to be added. Tags may
optionally take an argument, and closing tags may optionally include the
argument. (So `[list=1][/list=1]` versus `[list=1][/list]`)
###

# Import utility functions

{BBDocument, BBNode} = require "./bbdom"
tags = require './tags'
BlockList = require './blocks'
TagTokenizer = require './tokenizer'

{SimpleTag} = tags

###
A Text event, for when the parser discovers text.
###
class TextEvent
  ###
  Create a new Text event.
  @param [BBParse] state the parser generating the event
  @param [String] text the text of the event
  ###
  constructor: (@state, @text) ->

###
A Tag event, for when the parser discovers a tag.
###
class TagEvent
  ###
  Create a new Tag event.
  @param [BBParse] state the parser generating the event
  @param [Object] token an internal value
  ###
  constructor: (@state, token) ->
    @tag = token.name
    {@arg, @raw} = token

  ###
  This is a "special" method that indicates that the "current" tag should be
  closed. This only works during the onChildTag event. It's useful any time
  there should be a list of tags that are all children of the parent - which in
  practice is effectively only ever the `[*]` tag. Note that onChildTag must
  return true in order for this to take effect.
  ###
  closeTag: ->
    @closed = true

###
Parser state.
###
class BBParse extends BBNode
  ###
  Create a new parser state.
  @param [BBCodeParser] parser the parser which contains information on the
    supported tags.
  @see BBCodeParser#parse
  ###
  constructor: (@parser) ->
    @doc = null

  ###
  Determines if the given tag is the current tag at the top of the tag stack.
  @param [String] tag the tag to test
  @return [Boolean] whether the given tag was at the top of the tag stack
  ###
  isParentTag: (tag) ->
    return @tagStack.length > 0 and @tagStack[@tagStack.length-1].name == tag.toLowerCase()

  ###
  Determines if the given tags are the tags, in order, that are the top of the
  stack. Note that each tag must be present in order for this to return `true`.
  @param [String] tags an array of tags to test
  @return [Boolean] whether the list of tags at the top of the stack were the
    given tags
  ###
  isParentTags: (tags...) ->
    if @tagStack.length < tags.length
      # Well, clearly not going to work
    else
      # We're iterating forward through the tags and backwards through the
      # tag stack. CoffeeScript hates us for that.
      tagsIdx = 0
      stackIdx = @tagStack.length - 1
      while tagsIdx < tags.length
        if @tagStack[stackIdx].name != tags[tagsIdx].toLowerCase()
          return false
        tagsIdx++
        stackIdx--
      return true

  ###
  Run the actual parse on an input string. This method must not be called during
  an active parse.
  ###
  parse: (str) ->
    if @doc != null
      throw new Error("Do not call parse during an active parse");
    @doc = new BBDocument()
    tokenizer = new TagTokenizer(str)
    activeTag = null
    @tagStack = []
    @activeNode = @doc
    while tokenizer.hasNext()
      tok = tokenizer.next()
      switch tok.type
        when 'tag'
          # See what we can do with this
          tag = @parser.findTag(tok.name)
          if tag?
            # Counts, send it to the tag handler
            event = new TagEvent this, tok
            # First, see if the currently active tag allows children
            if @activeNode.onChildTag(event)
              if event.closed is true
                # In this case, the tag was explicitly closed and we should
                # pass off to the parent.
                if @activeNode is @doc
                  throw new Error("Cannot autoclose document node")
                @tagStack.pop()
                @activeNode = @tagStack[@tagStack.length - 1].node
              child = tag.onStartTag(event)
              if child?
                @tagStack.push {'name': tok.name, 'tag': tag, 'node': child}
                activeTag = tag
                @activeNode.appendChild child
                @activeNode = child
                continue
          # If we've fallen through any of the above, we're not handling the
          # tag, so treat it as a "dead" tag.
          @onDeadTag(tok.raw)
        when 'text'
          @activeNode.onText new TextEvent(this, tok.text);
        when 'endtag'
          # If this is an end tag, make sure it's an end tag for something that's
          # actually open.
          found = false
          if @tagStack.length > 0
            for i in [(@tagStack.length-1)..0]
              if @tagStack[i].name == tok.name
                # Found the tag this is closing. Everything above this should
                # receive a close event and we close down to this tag.
                found = true
                event = new TagEvent this, tok
                for j in [(@tagStack.length-1)..i]
                  @tagStack[j].node.onEndTag(event)
                # And rip off the end of the tag stack
                @tagStack.length = i
                if @tagStack.length > 0
                  @activeNode = @tagStack[@tagStack.length-1].node
                else
                  @activeNode = @doc
                break
          @onDeadTag(tok.raw) unless found
    rv = @doc
    @doc = null
    rv

  ###
  Receive notifcation of a "dead" tag - that is a tag that looks like a
  BBCode tag but was rejected, either because it wans't recognized as a known
  tag, or was recognized but the {Tag} class that handled that class rejected
  the event for some reason (such as an invalid argument).

  The default version of this method simply inserts the raw text of the dead
  tag into the current active node, which is generally how most BBCode
  implementations do with tags they can't handle for whatever reason.
  @param [String] raw
    the raw text that was rejected
  ###
  onDeadTag: (raw) ->
    # Some future version may do something different, this just does this:
    @activeNode.onText(new TextEvent(this, raw))

###
A Smiley contains a bunch of information on ways to convert text into a more
friendly "smiley".

This class isn't really used, but ...
###
class Smiley
  ###
  Create a new Smiley with the given options.
  @param [Object] options
    the options for the smiley
  ###
  constructor: (options) ->
    {@title, @image, @emoji, @match} = options
    if 'size' of options
      @imageWidth = options.size[0]
      @imageHeight = options.size[1]
    if typeof @match == 'string'
      @regexp = new RegExp(@match, 'g')
    else
      patterns = @match.map (pattern) ->
        pattern.replace(/([\\\[\]^${}.?+*()-])/g, '\\$1')
      @regexp = new RegExp(patterns.join('|'), 'g')
    if @emoji?
      if typeof @emoji == 'number'
        if @emoji > 0xFFFF
          high = Math.floor((@emoji - 0x10000) / 0x400) + 0xD800
          low = (@emoji - 0x10000) % 0x400 + 0xDC00
          @replacement = String.fromCharCode(high) + String.fromCharCode(low)
        else
          @replacement = String.fromCharCode(@emoji)
      else
        @replacement = @emoji
    else
      @replacement = "(oops)"
  ###
  Replace all instances of text that matches the smiley's base text.
  @param [String] text the text to replace
  @return [String] the text with all instances replaced with the replacement
    text
  ###
  replace: (text) ->
    text.replace @regexp, @replacement

class BBCodeParser
  #
  # The main BBCode parser object. It can either be instantiated directly or
  # called indirectly via the `bbcode` function.
  #
  constructor: (options) ->
    tags = BBCodeParser.DEFAULT_TAGS
    if options?.tags is "basic"
      tags = BBCodeParser.BASIC_TAGS
    # Clone the tags as a new object since they may be altered.
    @tags = {}
    for name, tag of tags
      @tags[name] = tag
    @smileys = BBCodeParser.DEFAULT_SMILIES.slice()

  # The default set of tags.
  @DEFAULT_TAGS:
    'url': new tags.URLTag(),
    'img': new tags.ImgTag(),
    'quote': new tags.QuoteTag(),
#    'pre': PreTag,
    'code': new tags.CodeTag(),
    'list': new tags.ListTag(),
    '*': new tags.ListItemTag(),
    'b': new SimpleTag("b"),
    'i': new SimpleTag("i"),
    'u': new SimpleTag("u"),
    's': new SimpleTag("strike"),
    'sub': new SimpleTag("sub"),
    'super': new SimpleTag("super")

  # A restrictive set of basic tags.
  @BASIC_TAGS:
    'url': new tags.URLTag(),
    'b': new SimpleTag("b"),
    'i': new SimpleTag("i"),
    'u': new SimpleTag("u"),
    's': new SimpleTag("strike"),
    'sub': new SimpleTag("sub"),
    'super': new SimpleTag("super")

  # Built-in smilies based on Emoji, I guess.
  @DEFAULT_SMILIES: [
    # How hard could this be? Well, Apple fucks up WHITE SMILING FACE (IMHO),
    # so instead I'm going to go with SMILING FACE WITH SMILING EYES.
    # (Aren't these names weird?)
    new Smiley({"title": "Smile", "emoji": 0x1F60A, "match": ":-?\\)"})
    new Smiley({"title": "Big Grin", "emoji": 0x1F601, "match": ":-?D"})
    new Smiley({"title": "Sad", "emoji": 0x1F622, "match": ":-?\\("})
    new Smiley({"title": "Cool", "emoji": 0x1F60E, "match": "8-?\\)"})
  ]

  ###
  Sets whether or not to use `<em>` and `<strong>` instead of `<i>` and `<b>`.
  It's debatable which is correct.

  Note that this modifies the `[i]` and `[b]` tags.

  @param [Boolean] useEmStrong `true` to use `<em>` and `<strong>`, `false`
    to use `<i>` and `<b>`
  ###
  setUseEmStrong: (useEmStrong) ->
    if (useEmStrong)
      @tags['i'] = new SimpleTag("em")
      @tags['b'] = new SimpleTag("strong")
    else
      @tags['i'] = BBCodeParser.DEFAULT_TAGS['i']
      @tags['b'] = BBCodeParser.DEFAULT_TAGS['b']

  ###
  Finds the {Tag} class with the given name.

  @param [String] name the name of the tag to look up
  @return [Tag] the Tag object for the tag of that name
  ###
  findTag: (name) ->
    name = name.toLowerCase()
    if name of @tags then @tags[name] else null

  ###
  The simplest method of adding a custom BBCode tag, this allows you to provide
  both a start and end bit of HTML to use for the tag.

  Note that tags created this way must have a start and end tag.

  The default `[b]`, `[i]`, `[u]`, `[s]`, `[super]`, and `[sub]` tags are all
  implemented using (something that could be) this method.
  @param [String] the name of the tag
  @param [String] start the HTML to use before the tag's contents
  @param [String] end the HTML to use after the tag's contents
  ###
  addSimpleTag: (name, start, end, overwrite=false) ->


  ###
  Parses a string containing BBCode, returning a {BBParse} that contains the
  result of the parse.
  ###
  parse: (str) ->
    str ?= "null"
    new BBParse(this).parse(str.toString())

  replaceSmileys: (html) ->
    for smiley in @smileys
      html = smiley.replace(html)
    html

defaultParser = new BBCodeParser()

###
The main module export function. When you `require 'bbcode'` this is the
function that's returned as the module.

@overload bbcode(str)
  Parse BBCode, returning HTML.

  @param [String] str a string containing the BBCode to parse
  @return [String] a string containing HTML that's the result of the parse

@overload bbcode(obj)
  Create a new {BBCodeParser} with the given options.

  @param [Object] obj options to give to {BBCodeParser}
  @return [BBCodeParser] a new `BBCodeParser`

@overload bbcode()
  Return a new {BBCodeParser} that was created with default options.

  @return [BBCodeParser] a new BBCodeParser with default options
###
bbcode = (obj) ->
  if not obj?
    return new BBCodeParser()
  if typeof obj == 'object'
    return new BBCodeParser(obj)
  else
    defaultParser.parse(obj.toString()).toBlocks().toHTML(defaultParser)

###
Don't document the export statement.
@nodoc
###
module.exports = bbcode

###
The {Tag} class, exported so you can access it via `bbcode.Tag`. This is
exported to allow the implementation of custom classes.
###
exports.Tag = tags.Tag
###
The {BBCodeParser} class.
###
exports.BBCodeParser = BBCodeParser
exports.BBNode = BBNode
exports.BBDocument = BBDocument

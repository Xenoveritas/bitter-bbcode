# Module for dealing with BBcode.
# This module is extensible, allowing "new" BBCode to be added.
# Tags may optionally take an argument, and closing tags may optionally require
# the closing argument to match. (So [list=1][/list=1] versus [list=1][/list])

# Import utility functions

{BBDocument, BBNode} = require "./bbdom"
tags = require './tags'
BlockList = require './blocks'
TagTokenizer = require './tokenizer'

{SimpleTag} = tags

class TextEvent
  constructor: (@state, @text) ->

class TagEvent
  constructor: (@state, token) ->
    @tag = token.name
    {@arg, @raw} = token

  # This is a "special" method that indicates that the "current" tag should be
  # closed. This only works during the onChildTag event. It's used for any time
  # there should be a list of tags that are all children of the parent - which
  # in practice is effectively only ever the [*] tag. Note that onChildTag must
  # return true in order for this to take effect.
  closeTag: ->
    @closed = true

# Parse state.
class BBParse extends BBNode
  constructor: (parser) ->
    @parser = parser

  isParentTag: (tag) ->
    return @tagStack.length > 0 and @tagStack[@tagStack.length-1].name == tag.toLowerCase()

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

  parse: (str) ->
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
    @doc

  onDeadTag: (raw) ->
    # Some future version may do something different, this just does this:
    @activeNode.onText(new TextEvent(this, raw))

class Smiley
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
  replace: (text) ->
    text.replace @regexp, @replacement

class BBCodeParser
  constructor: (options) ->
    tags = BBCodeParser.DEFAULT_TAGS
    if options?.tags is "basic"
      tags = BBCodeParser.BASIC_TAGS
    # Clone the tags as a new object since they may be altered.
    @tags = {}
    for name, tag of tags
      @tags[name] = tag
    @smileys = BBCodeParser.DEFAULT_SMILIES.slice()

  @ROOT_TAG: tags.Tag
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

  # Sets whether or not to use &lt;em&gt; and &lt;strong&gt; instead of
  # &lt;i&gt; and &lt;b&gt;. It's debatable which is correct.
  #
  setUseEmStrong: (useEmStrong) ->
    if (useEmStrong)
      @tags['i'] = new SimpleTag("em")
      @tags['b'] = new SimpleTag("strong")
    else
      @tags['i'] = BBCodeParser.DEFAULT_TAGS['i']
      @tags['b'] = BBCodeParser.DEFAULT_TAGS['b']

  findTag: (name) ->
    name = name.toLowerCase()
    if name of @tags then @tags[name] else null

  parse: (str) ->
    str ?= "null"
    new BBParse(this).parse(str.toString())

  replaceSmileys: (html) ->
    for smiley in @smileys
      html = smiley.replace(html)
    html

defaultParser = new BBCodeParser()

bbcode = (str) ->
  defaultParser.parse(str).toBlocks().transform(defaultParser)

module.exports = (str) ->
  bbcode(str)

exports.Tag = tags.Tag
exports.BBCodeParser = BBCodeParser
exports.BBNode = BBNode
exports.BBDocument = BBDocument

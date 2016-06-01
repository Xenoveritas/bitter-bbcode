# Module containing just the basic tag implementations.

bbdom = require './bbdom'
{isValidURL} = require "./htmlutil"

# A BBCode Tag.
#
# The Tag class is basically a BBNode factory - a class that can
# create BBNodes inside the parse tree.
#
# As such the tag class itself only handles receives events that create BBNodes.
# Once the BBNode is added and stuffed on the top of the stack, it receives
# further parse events until the parse is complete.
#
# The default Tag class can be given a BBNode class that will be instantiated
# whenever onStartTag is received. If the start tag has arguments, it will be
# assumed to be invalid and nothing will be added.
class Tag
  constructor: (nodeClass) ->
    @nodeClass = nodeClass

  # Indicates that a tag for this tag class is starting. This method should
  # create and return an appropriate BBNode that will handle the remaining
  # parse events. If this tag cannot handle this event (for example, the
  # arguments are invalid), it should return <code>null</code> in which case it
  # will be converted into a corresponding text event and delivered to the
  # current node.
  onStartTag: (event) ->
    if event.arg?
      null
    else
      new @nodeClass()

class SimpleTag extends Tag
  constructor: (htmlElement) ->
    super()
    if htmlElement?
      @htmlStart = "<#{htmlElement}>"
      @htmlEnd = "</#{htmlElement}>"

  onStartTag: (event) ->
    if event.arg?
      null
    else
      new bbdom.BBElement(@htmlStart, @htmlEnd)

class URLTag extends Tag
  constructor: ->
    super(null)

  onStartTag: (event) ->
    if event.arg?
      if isValidURL event.arg
        new bbdom.BBURLElement(event.raw, event.arg)
      else
        null
    else
      # How this gets handled depends on the content.
      new bbdom.BBURLElement(event.raw)

class ImgTag extends Tag
  constructor: ->
    super(null)

  onStartTag: (event) ->
    if event.arg?
      null
    else
      # Because we won't know if it's valid until after it ends, store the raw
      # value
      new bbdom.BBImgElement(event.raw)

class QuoteTag extends Tag
  constructor: ->
    super(null)

  onStartTag: (event) ->
    new bbdom.BBQuoteElement(event.arg)

class CodeTag extends Tag
  constructor: ->
    super(null)

  onStartTag: (event) ->
    # We can optionally have an arg that tells us what type of code it is
    new bbdom.BBCodeElement(event.raw)

class ListTag extends Tag
  constructor: ->
    super()

  onStartTag: (event) ->
    if event.arg?
      if event.arg of bbdom.BBListElement.ALLOWED_TYPES
        new bbdom.BBListElement(event.arg)
      else
        console.log("Invalid list type [" + event.arg + "]")
        null
    else
      new bbdom.BBListElement()

class ListItemTag extends Tag
  constructor: ->
    super("li")

  onStartTag: (event) ->
    # This is one of the few tags that cares about the state of the parse - this
    # only makes sense inside a [list] tag of some variety.
    if event.state.isParentTag("list")
      # OK, we can append an LI tag.
      new bbdom.BBListItemElement()
    else if event.state.isParentTags("*", "list")
      # Things are weird here - we want to close the parent list item.
    else
      # In any other case, ignore this.
      null

# Exports

exports.Tag = Tag
exports.SimpleTag = SimpleTag
exports.URLTag = URLTag
exports.ImgTag = ImgTag
exports.QuoteTag = QuoteTag
exports.CodeTag = CodeTag
exports.ListTag = ListTag
exports.ListItemTag = ListItemTag

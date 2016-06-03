###
Module containing tag implementations.
###

bbdom = require './bbdom'
{isValidURL} = require "./htmlutil"

###
A BBCode Tag.

The Tag class is basically a BBNode factory - a class that can create BBNodes
inside the parse tree.

As such the tag class itself only handles receives events that create BBNodes.
Once the BBNode is added and stuffed on the top of the stack, it receives
further parse events until the parse is complete.

The default Tag class can be given a BBNode class that will be instantiated
whenever onStartTag is received. If the start tag has arguments, it will be
assumed to be invalid and nothing will be added.
###
class Tag
  constructor: (nodeClass) ->
    @nodeClass = nodeClass

  ###
  Indicates that a tag for this tag class is starting. This method should create
  and return an appropriate BBNode that will handle the remaining parse events.
  If this tag cannot handle this event (for example, the arguments are invalid),
  it should return <code>null</code> in which case it will be converted into a
  corresponding text event and delivered to the current node.

  @param [TagEvent] event
    the start tag event
  @return [BBNode] either a new {BBNode} that provides the implementation of
    this tag or `null` if the event cannot be used to create a {BBNode}
  ###
  onStartTag: (event) ->
    if event.arg?
      null
    else
      new @nodeClass()

###
A very simple implementation of a tag. This works with any tag that is of the
form `[tag]Contents[/tag]`. It allows other tags to be nested within them and
simply surrounds its contents with the given starting and ending HTML.
###
class SimpleTag extends Tag
  ###
  Create a new SimpleTag.
  @overload constructor(htmlElement)
    @param [String] htmlElement
      the name of the HTML element. This is automatically surrounded with `<`
      and `>`: it's the same as calling the two argument caller with
      `"<#{htmlElement}>", "</#{htmlElement}>"`.
  @overload constructor(htmlStart, htmlEnd)
    @param [String] htmlStart
      the HTML to replace the start tag with
    @param [String] htmlEnd
      the HTML to replace the end tag with
  @overload constructor()
    You may, optionally, not pass in any HTML to use. In this case, the start
    and ending HTML is simply blank.
  ###
  constructor: (htmlStart, htmlEnd) ->
    super()
    if htmlEnd?
      @htmlStart = htmlStart
      @htmlEnd = htmlEnd
    else if htmlStart?
      @htmlStart = "<#{htmlStart}>"
      @htmlEnd = "</#{htmlStart}>"
    else
      @htmlStart = ""
      @htmlEnd = ""

  ###
  Returns `null` if the event has an argument.
  @param [TagEvent] event
    the event
  @return [BBElement] either a new {BBElement} with the starting and ending
    HTML for this node or `null` if there was an argument in the start tag
  ###
  onStartTag: (event) ->
    if event.arg?
      null
    else
      new bbdom.BBElement(@htmlStart, @htmlEnd)

###
Implementation of the `[url]` tag.
###
class URLTag extends Tag
  ###
  Construct a new URLTag.
  ###
  constructor: ->
    super(null)

  ###
  Start a new `[url]` tag. If given an argument, returns `null` if the URL isn't
  "valid" as determined by {htmlutil~isValidURL}. Otherwise returns a new
  {BBURLElement}.

  @param [TagEvent] event
    the open tag event
  @return [BBURLElement]
    the new `[url]` element or `null` if the argument was rejected
  ###
  onStartTag: (event) ->
    if event.arg?
      if isValidURL event.arg
        new bbdom.BBURLElement(event.raw, event.arg)
      else
        null
    else
      # How this gets handled depends on the content.
      new bbdom.BBURLElement(event.raw)

###
Implementation of the `[img]` tag.
###
class ImgTag extends Tag
  ###
  Construct a new ImgTag.
  ###
  constructor: ->
    super(null)

  ###
  Start a new `[img]` tag - `[img]` tags do not accept arguments so this returns
  `null` if there is an argument.

  @param [TagEvent] event
    the open tag event
  @return [BBImgElement]
    the new `[img]` element or `null` if the tag had an argument
  ###
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

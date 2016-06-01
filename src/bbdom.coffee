# "DOM" implementation for BBCode.

BlockList = require './blocks'
{escapeHTML, escapeHTMLAttr, isValidURL} = require "./htmlutil"

# A node in a BBCode document.
class BBNode
  constructor: ->
    @parent = null
    @children = []

  # Receives notification that a child tag has been found. This is sent prior to
  # the tag being sent an onStartTag event and may be used to prevent the tag
  # event from being sent at all. If this node doesn't accept children, this
  # may instead return false, which will halt further processing and likely
  # cause an onText event.
  onChildTag: (event) ->
    false

  # Receives notification that an end tag was received. The end tag may or may
  # not correspond to the opening tag.
  onEndTag: (event) ->
    false

  onText: (event) ->
    @appendText(event.text)

  appendChild: (child) ->
    if child.parent != null
      throw new Error("Attempting to add child that already has a parent")
    child.parent = this
    @children.push(child)
    child

  appendText: (text) ->
    @appendChild(new BBText(text))

  # Convert this element to a block that can later be converted to HTML. The
  # process is a two-step process to avoid translations of smileys and the like
  # within certain blocks.
  makeBlocks: (list) ->
    for child in @children
      child.makeBlocks(list)

class BBElement extends BBNode
  constructor: (@htmlStart, @htmlEnd, @nests = true) ->
    super()

  onChildTag: (event) ->
    @nests

  makeBlocks: (list) ->
    list.append(@htmlStart)
    super(list)
    list.append(@htmlEnd)

class BBURLElement extends BBElement
  constructor: (@rawStart, @url) ->
    super("<a>", "</a>")

  onChildTag: (event) ->
    # If we have a URL, we can just return true. Otherwise, we have to decide
    # if we want to allow [ and ] in URLs. Right now, I'm deciding "no" which
    # means we should allow nesting and ignore the contents.
    true

  _makeLink: (url) ->
    "<a href=\"#{escapeHTMLAttr(url)}\" rel=\"nofollow\">"

  makeBlocks: (list) ->
    if @url?
      @htmlStart = @_makeLink(@url)
    else
      # If we have no URL but our content is solely text, see if we can use it
      # as a URL.
      if @children.length is 1
        child = @children[0]
        if child instanceof BBText
          url = child.data
          if isValidURL url
            @htmlStart = @_makeLink(url)
            return super(list)
      @htmlStart = escapeHTML(@rawStart)
      @htmlEnd = "[/url]"
    super(list)

class BBQuoteElement extends BBElement
  constructor: (quoted) ->
    super("<blockquote>", "</blockquote>")
    # The "quoted" part should be parsed as BBCode as well. For some reason.
    # This doesn't, yet.
    if quoted?
      @htmlStart = "<div class=\"quoted-name\">#{escapeHTML(quoted)}</div>" + @htmlStart

class BBImgElement extends BBNode
  constructor: (@rawStart) ->
    super
    @url = []
  onChildTag: (event) ->
    false
  onText: (event) ->
    @url.push(event.text)
  onEndTag: (event) ->
    if event.tag == 'img'
      @rawEnd = event.raw
    else
      @rawEnd = ""
  makeBlocks: (list) ->
    url = @url.join('')
    if isValidURL(url)
      list.appendHTML("<img src=\"#{escapeHTMLAttr(url)}\">")
    else
      list.appendHTML(escapeHTML(@rawStart + url + @rawEnd))

class BBListElement extends BBElement
  constructor: (@type) ->
    if @type of BBListElement.ALLOWED_TYPES
      # This is an interesting question: set a CSS class or set the style?
      # For now, do both: that way it works if unstyled AND it can be styled.
      listStyle = BBListElement.ALLOWED_TYPES[@type]
      start = "<ol class=\"bbcode-list-#{listStyle}\" style=\"list-style-type: #{listStyle}\">"
      end = "</ol>"
    else
      start = "<ul>"
      end = "</ul>"
    super(start, end, true)

  @ALLOWED_TYPES = {
    '1': 'decimal',
    'a': 'lower-alpha',
    'A': 'upper-alpha'
  }

class BBListItemElement extends BBElement
  constructor: ->
    super("<li>", "</li>", true)

  onChildTag: (event) ->
    if event.tag == '*'
      event.closeTag()
    # In any case, allow it
    true

class BBPreElement extends BBNode
  constructor: (@element = "pre") ->
    super
    @content = []
  onChildTag: (event) ->
    false
  onText: (event) ->
    @content.push(event.text)
  makeBlocks: (list) ->
    list.appendRawHTML("<#{@element}>#{escapeHTML(@content.join(''))}</#{@element}>")

class BBCodeElement extends BBPreElement
  constructor: (@codeType) ->
    super
  makeBlocks: (list) ->
    list.appendRawHTML("<pre><code>#{escapeHTML(@content.join(''))}</code></pre>")

class BBText extends BBNode
  data: ""
  constructor: (data) ->
    super()
    @data = data
  makeBlocks: (list) ->
    list.append(escapeHTML(@data))

# Root of the BBCode document.
class BBDocument extends BBNode
  constructor: ->
    super
  onChildTag: (event) ->
    true
  toBlocks: ->
    list = new BlockList()
    @makeBlocks(list)
    list

# Exports

exports.BBNode = BBNode
exports.BBElement = BBElement

exports.BBURLElement = BBURLElement
exports.BBQuoteElement = BBQuoteElement
exports.BBImgElement = BBImgElement
exports.BBPreElement = BBPreElement
exports.BBCodeElement = BBCodeElement
exports.BBListElement = BBListElement
exports.BBListItemElement = BBListItemElement

exports.BBText = BBText
exports.BBDocument = BBDocument

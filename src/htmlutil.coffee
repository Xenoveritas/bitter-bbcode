# Basic HTML utilities.

###
Escapes basic HTML.
@param [String] str
  the raw string
@return [String]
  the raw string with `<`, `>`, and `&` translated to `&lt;`, `&gt;`, and `&amp;`
###
exports.escapeHTML = (str) ->
  str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')


###
Escapes a string so that it can be placed into an HTML attribute.
@param [String] str
  the raw string
@return [String]
  the raw string with `<`, `>`, `&`, `"`, and `'` translated to `&lt;`, `&gt;`,
  `&amp;`, `&quot;` and `&#39;`
###
exports.escapeHTMLAttr = (str) ->
  exports.escapeHTML(str).replace(/"/g, '&quot;').replace(/'/g, '&#39;')

###
Utility for converting newlines into HTML paragraphs or line breaks.

Essentially, double newlines become paragraphs and single newlines becomes
`<br>`s.

@param [String] text
  the text to convert newlines in
@return [String]
  the string with HTML paragraphs and breaks added
###
exports.convertNewlinesToHTML = (text) ->
  if (text.length == 0)
    return "<p></p>";
  # First, normalize newlines
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n")
  # Remove the final newline if there is one
  if (text.charAt(text.length-1) == "\n")
    text = text.substring(0,text.length-1)
  # And convert
  text = text.replace(/\n/g, "<br>\n").replace(/<br>\n<br>\n/g, "</p>\n\n<p>")
  '<p>' + text + '</p>'

###
Checks to see if a URL is "valid" - currently that means starts with
"http", "https", or "ftp".

Note: This function is almost certainly migrating to {BBCodeParser} at some
point in order to make what constitutes a "valid" URL configurable.

@param [String] url
  the URL to check
@return [Boolean]
  if the given URL is considered valid
###
exports.isValidURL = (url) ->
  /^(?:https?|ftp):\/\//i.test(url)

# Basic HTML utilities.

# Escapes basic HTML.
exports.escapeHTML = escapeHTML = (str) ->
  str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

# Escapes HTML that will be placed into an attribute
exports.escapeHTMLAttr = (str) ->
  escapeHTML(str).replace(/"/g, '&quot;').replace(/'/g, '&#39;')

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

# Checks to see if a URL is "valid" - currently that means starts with
# "http", "https", or "ftp".
exports.isValidURL = (url) ->
  /^(?:https?|ftp):\/\//i.test(url)

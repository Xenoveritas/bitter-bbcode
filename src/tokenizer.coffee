# Module for the tokenizer.

class TagTokenizer
  constructor: (str) ->
    @str = str
    @currentOffset = 0
    @nextToken = @_next()

  # Determines if the text is a valid tag (allowed between [ and ])
  isValidTag: (tag) ->
    /^\/?(?:[A-Za-z]+|\*)(?:=[^\]]*|="[^"]*")?$/.test(tag)

  hasNext: ->
    @nextToken != null

  next: ->
    if (@nextToken == null)
      throw Error("No more tokens")
    result = @nextToken
    if (@nextToken.type == 'text')
      # Merge text tokens if there are any
      nextNext = @_next()
      while nextNext != null and nextNext.type == 'text'
        result.text += nextNext.text
        nextNext = @_next()
      @nextToken = nextNext
    else
      @nextToken = @_next()
    if (result.type == 'tag' and result.name.charAt(0) == '/')
      result.name = result.name.substring(1)
      result.type = 'endtag';
    result

  #
  # Internal implementation of next, before multiple text tokens are merged.
  #
  _next: ->
    #console.log("_next(%d)", this.currentOffset);
    if (@currentOffset >= @str.length)
      return null;
    # This is fairly simple: are we starting with a [?
    if (@str.charAt(@currentOffset) == '[')
      # Assume this is a tag for now
      idx = @str.indexOf(']', @currentOffset)
      if (idx < 0)
        # Last token! Because we can never find an end tag
        tok = { type: 'text', text: @str.substring(@currentOffset) }
        @currentOffset = @str.length
        return tok
      # Otherwise, grab the contents as a tag, maybe
      tag = @str.substring(@currentOffset+1, idx)
      # Is this a real tag?
      if (@isValidTag(tag))
        # OK - now we split it into a tag and an argument (if any)
        name = tag;
        arg = null;
        eqIdx = tag.indexOf('=');
        if (eqIdx >= 0)
          name = tag.substring(0, eqIdx);
          arg = tag.substring(eqIdx + 1);
          # If the argument is surrounded by quotes, remove them
          if (arg.charAt(0) == '"' and arg.charAt(arg.length-1) == '"')
            arg.substring(1, arg.length-1);
        raw = @str.substring(@currentOffset, idx+1);
        @currentOffset = idx+1;
        # Always canonicalize the tokenized name to lower case
        return { type: 'tag', name: name.toLowerCase(), arg: arg, raw: raw }
      else
        # We don't like this tag, so we just return the current text
        # element, advance by one, and continue.
        @currentOffset++
        return { type: 'text', text: '[' }
    else
      idx = @str.indexOf('[', @currentOffset)
      if idx < 0
        # last text token
        tok = { type: 'text', text: @str.substring(@currentOffset) }
        @currentOffset = @str.length;
        return tok;
      else
        tok = { type: 'text', text: @str.substring(@currentOffset, idx) }
        @currentOffset = idx
        return tok

module.exports = TagTokenizer

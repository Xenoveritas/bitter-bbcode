bbcode = require '../lib/bbcode'
expect = require('chai').expect

describe "BBCode parser", ->

  describe "when parsing text", ->
    it "properly escapes HTML characters", ->
      text = bbcode('<script type="text/javascript">alert("Whoops");</script>')
      expect(text).to.equal """
        <p>&lt;script type="text/javascript"&gt;alert("Whoops");&lt;/script&gt;</p>
      """

  describe "when parsing tags", ->
    it "ignores case", ->
      text = bbcode "[b]Test[/b]"
      expect(text).to.equal "<p><b>Test</b></p>"
      text = bbcode "[b]Test[/B]"
      expect(text).to.equal "<p><b>Test</b></p>"
      text = bbcode "[B]Test[/b]"
      expect(text).to.equal "<p><b>Test</b></p>"
      text = bbcode "[B]Test[/B]"
      expect(text).to.equal "<p><b>Test</b></p>"
    it "handles nesting correctly", ->
      text = bbcode "[b][i]Test[/i][/b]"
      expect(text).to.equal "<p><b><i>Test</i></b></p>"
    it "handles tags over multiple lines", ->
      text = bbcode """
        [b]Bold this text
        [i]Bold and italicize this text
        [/i][/b]
      """
      expect(text).to.equal """
        <p><b>Bold this text<br>
        <i>Bold and italicize this text<br>
        </i></b></p>
      """

  describe "when handling [url] tags", ->
    it "ignores tags without URLs in them", ->
      text = bbcode("[url]not a url[/url]")
      expect(text).to.equal "<p>[url]not a url[/url]</p>"
    it "allows HTTP URLs", ->
      text = bbcode("[url=http://www.example.com]test[/url]")
      expect(text).to.equal "<p><a href=\"http://www.example.com\" rel=\"nofollow\">test</a></p>"
    it "allows HTTP URLs regardless of case", ->
      text = bbcode("[url=HTTP://WWW.EXAMPLE.COM]test[/url]")
      expect(text).to.equal "<p><a href=\"HTTP://WWW.EXAMPLE.COM\" rel=\"nofollow\">test</a></p>"
    it "allows HTTPS URLs", ->
      text = bbcode("[url=https://www.example.com]test[/url]")
      expect(text).to.equal "<p><a href=\"https://www.example.com\" rel=\"nofollow\">test</a></p>"
    it "allows HTTPS URLs regardless of case", ->
      text = bbcode("[url=HTTPS://WWW.EXAMPLE.COM]test[/url]")
      expect(text).to.equal "<p><a href=\"HTTPS://WWW.EXAMPLE.COM\" rel=\"nofollow\">test</a></p>"

  describe "when handling [img] tags", ->
    it "ignores tags without URLs in them", ->
      text = bbcode("[img]not a url[/img]")
      expect(text).to.equal "<p>[img]not a url[/img]</p>"

  # describe "when handling [code] tags", ->
  #   it "includes start and end tags", ->
  #     runs ->
  #       text = bbcode("""
  #         [code]
  #         This is some code.
  #         [/code]
  #       """)
  #       expect(text).to.equal """
  #         <pre>
  #         This is some code.
  #         </pre>
  #       """

  describe "when converting newlines", ->
    it "creates paragraphs", ->
      html = bbcode("""
        This is some text that is split into paragraphs.

        This is the second paragraph. It should be in its own tag.
      """)
      expect(html).to.equal """
        <p>This is some text that is split into paragraphs.</p>

        <p>This is the second paragraph. It should be in its own tag.</p>
      """
    it "deals with single lines", ->
      html = bbcode("""
        This is some text that is split into lines.
        Each line should end in a break.
        The entire block should be in a paragraph.
      """)
      expect(html).to.equal """
        <p>This is some text that is split into lines.<br>
        Each line should end in a break.<br>
        The entire block should be in a paragraph.</p>
      """

    it "doesn't include a double newline at the end", ->
      text = bbcode("""
        This is a block of text
        as if it had come from
        the editor

      """)
      expect(text).to.equal("""
        <p>This is a block of text<br>
        as if it had come from<br>
        the editor</p>
      """)

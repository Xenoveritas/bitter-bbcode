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
    it "allows HTTP URLs in an arg-less [url] tag", ->
      expect(bbcode("[url]http://www.example.com/[/url]")).to.equal "<p><a href=\"http://www.example.com/\" rel=\"nofollow\">http://www.example.com/</a></p>"
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

  describe "when handling [code] tags", ->
    it "includes start and end tags", ->
      text = bbcode("""
        [code]
        This is some code.
        [/code]
      """)
      expect(text).to.equal """
        <pre><code>
        This is some code.
        </code></pre>
      """

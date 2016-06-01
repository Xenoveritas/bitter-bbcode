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
    it "handles tag soup", ->
      # This test is likely going to be changed in the future. It shows
      # current behavior which may or may not be correct.
      expect(bbcode("[b][i]Tag[/b] soup[/i]")).to.equal "<p><b><i>Tag</i></b> soup[/i]</p>"
    it "handles closing tags without opening tags", ->
      expect(bbcode("[/b] Nothing [/b]")).to.equal "<p>[/b] Nothing [/b]</p>"
    it "handles open tags that are never closed", ->
      expect(bbcode("[b][i]It never ends.")).to.equal "<p><b><i>It never ends.</i></b></p>"
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

  describe "when handling [list] tags", ->
    describe "with no arguments", ->
      it "generates a list", ->
        expect(bbcode("""
          [list][*]Item one
          [*]Item two
          [*]Item three[/list]
        """)).to.equal """
          <p><ul><li>Item one<br>
          </li><li>Item two<br>
          </li><li>Item three</li></ul></p>
        """
        # FIXME: The bottom is what we really want but isn't possible. Yet.
        # """)).to.equal """
        #   <ul><li>Item one
        #   <li>Item two
        #   <li>Item three</ul>
        # """
    # FIXME: The tests for 1, a, and A are all basically identical and should be
    # generated instead of copy-pasted
    describe "with argument 1", ->
      it "generates an ordered list", ->
        # It could also be argued that this should return a blank list.
        expect(bbcode("""
          [list=1][*]Item one
          [*]Item two
          [*]Item three[/list]
        """)).to.equal """
          <p><ol class="bbcode-list-decimal" style="list-style-type: decimal"><li>Item one<br>
          </li><li>Item two<br>
          </li><li>Item three</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing
    describe "with argument 1 duplicated in the closing tag", ->
      it "generates an ordered list", ->
        # It could also be argued that this should return a blank list.
        expect(bbcode("""
          [list=1][*]Item one
          [*]Item two
          [*]Item three[/list=1]
        """)).to.equal """
          <p><ol class="bbcode-list-decimal" style="list-style-type: decimal"><li>Item one<br>
          </li><li>Item two<br>
          </li><li>Item three</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing
    describe "with argument a", ->
      it "generates a lower-alpha ordered list", ->
        expect(bbcode("""
          [list=a][*]Item a
          [*]Item b
          [*]Item c[/list]
        """)).to.equal """
          <p><ol class="bbcode-list-lower-alpha" style="list-style-type: lower-alpha"><li>Item a<br>
          </li><li>Item b<br>
          </li><li>Item c</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing
    describe "with argument a duplicated in the closing tag", ->
      it "generates a lower-alpha ordered list", ->
        expect(bbcode("""
          [list=a][*]Item a
          [*]Item b
          [*]Item c[/list=a]
        """)).to.equal """
          <p><ol class="bbcode-list-lower-alpha" style="list-style-type: lower-alpha"><li>Item a<br>
          </li><li>Item b<br>
          </li><li>Item c</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing
    describe "with argument A", ->
      it "generates an upper-alpha ordered list", ->
        expect(bbcode("""
          [list=A][*]Item A
          [*]Item B
          [*]Item C[/list]
        """)).to.equal """
          <p><ol class="bbcode-list-upper-alpha" style="list-style-type: upper-alpha"><li>Item A<br>
          </li><li>Item B<br>
          </li><li>Item C</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing
    describe "with argument A duplicated in the closing tag", ->
      it "generates an upper-alpha ordered list", ->
        expect(bbcode("""
          [list=A][*]Item A
          [*]Item B
          [*]Item C[/list=A]
        """)).to.equal """
          <p><ol class="bbcode-list-upper-alpha" style="list-style-type: upper-alpha"><li>Item A<br>
          </li><li>Item B<br>
          </li><li>Item C</li></ol></p>
        """
        # FIXME: Same caveat as the [list] test - break and paragraph generation still need fixing

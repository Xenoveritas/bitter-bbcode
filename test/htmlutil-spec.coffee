htmlutil = require '../lib/htmlutil'
expect = require('chai').expect

describe "HTML utility functions", ->
  describe "escapeHTML", ->
    it "escapes <, >, and &", ->
      expect(htmlutil.escapeHTML('1 < 2 & 2 > 1')).to.equal "1 &lt; 2 &amp; 2 &gt; 1"
    it "doesn't escape \" and '", ->
      expect(htmlutil.escapeHTML("\"It's a wonderful world.\"")).to.equal "\"It's a wonderful world.\""

  describe "escapeHTMLAttr", ->
    it "escapes <, >, and &", ->
      expect(htmlutil.escapeHTMLAttr('1 < 2 & 2 > 1')).to.equal "1 &lt; 2 &amp; 2 &gt; 1"
    it "escapes \" and '", ->
      expect(htmlutil.escapeHTMLAttr("\"It's a wonderful world.\"")).to.equal "&quot;It&#39;s a wonderful world.&quot;"

  describe "convertNewlinesToHTML", ->
    it "creates paragraphs", ->
      html = htmlutil.convertNewlinesToHTML("""
        This is some text that is split into paragraphs.

        This is the second paragraph. It should be in its own tag.
      """)
      expect(html).to.equal """
        <p>This is some text that is split into paragraphs.</p>

        <p>This is the second paragraph. It should be in its own tag.</p>
      """
    it "deals with single lines", ->
      html = htmlutil.convertNewlinesToHTML("""
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
      text = htmlutil.convertNewlinesToHTML("""
        This is a block of text
        as if it had come from
        the editor

      """)
      expect(text).to.equal("""
        <p>This is a block of text<br>
        as if it had come from<br>
        the editor</p>
      """)

TagTokenizer = require '../lib/tokenizer'
expect = require('chai').expect

describe "BBCode tokenizer", ->

  describe "tag tokenizer", ->
    it "canonicalizes tags to lower-case", ->
      token = new TagTokenizer("[TEST] tag").next()
      expect(token).to.not.be.null
      expect(token.type).to.equal "tag"
      expect(token.name).to.equal "test"

    it "allows [*] as a tag", ->
      token = new TagTokenizer("[*] Test").next()
      expect(token).to.not.be.null
      expect(token.type).to.equal "tag"
      expect(token.name).to.equal "*"

    it "allows a tag at the start", ->
      token = new TagTokenizer("[tag] Test").next()
      expect(token).to.not.be.null
      expect(token.type).to.equal "tag"
      expect(token.name).to.equal "tag"

    it "allows a tag at the end", ->
      tokenizer = new TagTokenizer("Tag [test]")
      token = tokenizer.next()
      expect(token).to.not.be.null
      expect(token.type).to.equal "text"
      expect(token.text).to.equal "Tag "
      token = tokenizer.next()
      expect(token).to.not.be.null
      expect(token.type).to.equal "tag"
      expect(token.name).to.equal "test"
      expect(tokenizer.hasNext()).to.be.false

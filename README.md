# bbcode

A simple BBCode parser.

This is split off from my original implementation of a BBCode parser in the BBCode preview package.

It supports very simplistic BBCode at present:

```bbcode
[b]Bold[/b]
[i]Italic[/i]
[u]Underline[/u]
[url=https://www.github.com/]GitHub[/url]
```

Becomes:

```html
<p><b>Bold</b><br>
<i>Italic</i><br>
<u>Underline</u><br>
<a href="https://www.github.com/">GitHub</a></p>
```

## Basic Usage

```javascript
var bbcode = require('bbcode');

bbcode("Some [b]text[/b]");
// Result: "<p>Some <b>text</b></p>");
```

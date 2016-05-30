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

## BBCode Compatibility

This is currently targeted at supporting phpBB-style BBCode, but with the ability to expand it to support the BBCode other forums support.

### Supported BBCode Table

BBCode            | Description                                        | Supported?
------------------|----------------------------------------------------|-------------------
[b]               | Bold text                                          | :white_check_mark:
[i]               | Italic text                                        | :white_check_mark:
[u]               | Underline text                                     | :white_check_mark:
[s]               | Strike-though text                                 | :white_check_mark:
[sub]             | Subscript text                                     | :white_check_mark:
[super]           | Superscript text                                   | :white_check_mark:
[color=*color*]   | Text in the specified color                        | :x:
[size=*size*]     | Change text size                                   | :x:
[url]             | Link                                               | :x:
[url=*url*]       | Link                                               | :white_check_mark:
[img]             | Image                                              | :white_check_mark:
[list]            | Unordered List                                     | :x:
[list=1]          | Numerically Ordered List                           | :x:
[list=a]          | Alphabetically Ordered List                        | :x:
[quote]           | Quote                                              | :white_check_mark:
[quote="*name*"]  | Quote with a given name                            | :white_check_mark:
[code]            | BBCode ignored code block                          | :warning:
[code=*language*] | BBCode ignored code block with syntax highlighting | :warning:

### BBCode by bulletin board software

BBCode               | phpBB
---------------------|-------------------
[b]                  | :white_check_mark:
[i]                  | :white_check_mark:
[u]                  | :white_check_mark:
[color=*color*]      | :white_check_mark:
[color="*color*"]    | :x:
[size=*size*]        | :white_check_mark:
[size="*size*"]      | :x:
[s]                  | :x:
[sub]                | :x:
[super]              | :x:
[url]                | :white_check_mark:
[url=*url*]          | :white_check_mark:
[url="*url*"]        | :x:
[img]                | :white_check_mark:
[list]               | :white_check_mark:
[list=1]...[/list]   | :white_check_mark:
[list=1]...[/list=1] | :x:
[list=a]...[/list]   | :white_check_mark:
[list=a]...[/list=a] | :x:
[quote]              | :white_check_mark:
[quote=*name*]       | :x:
[quote="*name*"]     | :white_check_mark:
[code]               | :white_check_mark:
[code=*language*]    | :white_check_mark:
[code="*language*"]  | :x:

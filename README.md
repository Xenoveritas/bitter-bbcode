# bitter-bbcode

A simple BBCode parser.

This is split off from my original implementation of a BBCode parser in the BBCode preview package. The concept is to support some form of "generic" BBCode out of the box that covers the majority of software platforms out there, while being extensible enough that new BBCodes can be added without breaking anything.

Because it parses to a "DOM" it should be possible to export to destinations that aren't BBCode, for example, it should be possible to write a BBCode to Markdown translator.

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

## More advanced use

```javascript
var bbcode = require('bbcode');
var parser = bbcode();
var bbdom = parser.parse("[b]Some BB Code[/b]");
blocks = bbdom.toBlocks();
blocks.toHTML();
```

## BBCode Compatibility

This is currently targeted at supporting phpBB-style BBCode. The ultimate goal is to make it configurable enough that various BBCode styles can be supported, including a default "global" mode that accepts the majority of BBCode used by the majority of forums that support BBCode.

### Supported BBCode Table

The following describes the BBCode available in popular BBCode implementations compared to this implementation. If the tag is in the table and unless otherwise noted, it is planned to be implemented in the future.

BBCode            | Description                                        | Supported?
------------------|----------------------------------------------------|-------------------
[b]               | Bold text                                          | :white_check_mark:
[i]               | Italic text                                        | :white_check_mark:
[u]               | Underline text                                     | :white_check_mark:
[s]               | Strike-though text                                 | :white_check_mark:
[sub]             | Subscript text                                     | :white_check_mark:
[super]           | Superscript text                                   | :white_check_mark:
[fixed]           | Fixed-width text                                   | :x:
[color=*color*]   | Text in the specified color                        | :x:
[size=*size*]     | Change text size                                   | :x:
[url]             | Link                                               | :white_check_mark:
[url=*url*]       | Link                                               | :white_check_mark:
[email]           | Link an email address                              | :x:
[email=*email*]   | Link an email address                              | :x:
[img]             | Image                                              | :white_check_mark:
[timg]            | Thumbnailed image                                  | :x:¹
[flash]           | Embedding flash content                            | :x:²
[video]           | Embedding video content                            | :x:¹
[list]            | Unordered List                                     | :white_check_mark:
[list=1]          | Numerically Ordered List                           | :white_check_mark:
[list=a]          | Alphabetically Ordered List                        | :white_check_mark:
[quote]           | Quote                                              | :white_check_mark:
[quote="*name*"]  | Quote with a given name                            | :white_check_mark:
[code]            | BBCode ignored code block                          | :white_check_mark:
[code=*language*] | BBCode ignored code block with syntax highlighting | :warning:³
[php]             | Same as [code=php]                                 | :x:

¹ It is unlikely this tag will ever be enabled by default<br>
² It is unlikely that embedding Flash will ever be supported by this library<br>
³ Syntax highlighting is not supported at present

### BBCode by bulletin board software

Check out the [full comparison tables](compat/Comparison Tables.md) for details about how this library differs from other BBCode implementations.

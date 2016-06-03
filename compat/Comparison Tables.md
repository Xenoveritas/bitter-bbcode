# BBCode Comparison Tables

First, a list of the various tested forums and forums that may be tested in the future:

 * This library - the current version of the library containing this file
 * [phpBB](https://www.phpbb.com/) - specifically phpBB 3 and the BBCode containing within the default install
 * [SAVB](https://forums.somethingawful.com/) - Something Awful's vBulletin variant. Hopefully BBCode tags that work there will work with the majority of vBulletin forums such as the [Steam forums](http://forums.steampowered.com/forums/).

And some other BBCode-supporting forums that may be tested "sometime in the future":

 * [Vanilla Forums](https://vanillaforums.org/)
 * The Drupal BBCode module does
 * Maybe something based on [the PHP bbcode module](http://php.net/manual/en/book.bbcode.php) assuming anyone really uses it

## Basic Handling

BBCode                | This library       | phpBB                  | SAVB
----------------------|--------------------|------------------------|---
Unclosed tags         | Auto-closed        | Ignored                | :question:
Case-sensitivity      | None               | None                   | :question:
Bad tags              | Left as-is         | Left as-is             | :question:
[size=(out of range)] | :x:                | Aborts post with error | :x:

## Tag Support

BBCode               | This library       | phpBB              | SAVB
---------------------|--------------------|--------------------|------
[b]                  | :white_check_mark: | :white_check_mark: | :white_check_mark:
[i]                  | :white_check_mark: | :white_check_mark: | :white_check_mark:
[u]                  | :white_check_mark: | :white_check_mark: | :white_check_mark:
[color=*color*]      | :x:                | :white_check_mark: | :question:
[color="*color*"]    | :x:                | :x:                | :question:
[size=*size*]        | :x:                | :white_check_mark: | :question:
[size="*size*"]      | :x:                | :x:                | :question:
[s]                  | :white_check_mark: | :x:                | :white_check_mark:
[sub]                | :white_check_mark: | :x:                | :white_check_mark:
[super]              | :white_check_mark: | :x:                | :white_check_mark:
[fixed]              | :x:                | :x:                | :white_check_mark:
[url]                | :white_check_mark: | :white_check_mark: | :white_check_mark:
[url=*url*]          | :white_check_mark: | :white_check_mark: | :white_check_mark:
[url="*url*"]        | :white_check_mark: | :x:                | :question:
[email]              | :x:                | :white_check_mark: | :white_check_mark:
[email=*email*]      | :x:                | :question:         | :white_check_mark:
[email="*email*"]    | :x:                | :question:         | :question:
[img]                | :white_check_mark: | :white_check_mark: | :white_check_mark:
[timg]               | :x:                | :x:                | :white_check_mark:
[video]              | :x:                | :x:                | :white_check_mark:
[list]               | :white_check_mark: | :white_check_mark: | :white_check_mark:
[list=1]...[/list]   | :white_check_mark: | :white_check_mark: | :question:
[list=1]...[/list=1] | :white_check_mark: | :x:                | :white_check_mark:
[list=a]...[/list]   | :white_check_mark: | :white_check_mark: | :question:
[list=a]...[/list=a] | :white_check_mark: | :x:                | :question:
[quote]              | :white_check_mark: | :white_check_mark: | :white_check_mark:
[quote=*name*]       | :white_check_mark: | :x:                | :question:
[quote="*name*"]     | :white_check_mark: | :white_check_mark: | :white_check_mark:
[pre]                | :x:                | :x:                | :white_check_mark:
[code]               | :white_check_mark: | :white_check_mark: | :white_check_mark:
[code=*language*]    | :white_check_mark: | :white_check_mark: | :white_check_mark:
[code="*language*"]  | :white_check_mark: | :x:                | :question:
[php]                | :x:                | :x:                | :white_check_mark:
[spoiler]            | :x:                | :x:                | :white_check_mark:

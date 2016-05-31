# BBCode Comparison Tables

## Basic Handling

BBCode                | This libary        | phpBB
----------------------|--------------------|-----------
Unclosed tags         | Auto-closed        | Ignored
Case-sensitivity      | None               | None
Bad tags              | Left as-is         | Left as-is
[size=(out of range)] | :x:                | Aborts post with error

## Tag Support

BBCode               | This libary        | phpBB
---------------------|--------------------|-----------
[b]                  | :white_check_mark: | :white_check_mark:
[i]                  | :white_check_mark: | :white_check_mark:
[u]                  | :white_check_mark: | :white_check_mark:
[color=*color*]      | :x:                | :white_check_mark:
[color="*color*"]    | :x:                | :x:
[size=*size*]        | :x:                | :white_check_mark:
[size="*size*"]      | :x:                | :x:
[s]                  | :white_check_mark: | :x:
[sub]                | :white_check_mark: | :x:
[super]              | :white_check_mark: | :x:
[url]                | :white_check_mark: | :white_check_mark:
[url=*url*]          | :white_check_mark: | :white_check_mark:
[url="*url*"]        | :white_check_mark: | :x:
[img]                | :white_check_mark: | :white_check_mark:
[list]               | :x:                | :white_check_mark:
[list=1]...[/list]   | :x:                | :white_check_mark:
[list=1]...[/list=1] | :x:                | :x:
[list=a]...[/list]   | :x:                | :white_check_mark:
[list=a]...[/list=a] | :x:                | :x:
[quote]              | :white_check_mark: | :white_check_mark:
[quote=*name*]       | :white_check_mark: | :x:
[quote="*name*"]     | :white_check_mark: | :white_check_mark:
[code]               | :white_check_mark: | :white_check_mark:
[code=*language*]    | :white_check_mark: | :white_check_mark:
[code="*language*"]  | :white_check_mark: | :x:

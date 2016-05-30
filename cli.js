#!/usr/bin/env node

// Simple stub for running the BBCode parser over input files to translate into
// BBCode. There's a good chance that a future version of this will move the
// CLI into its own module because concpetually this is a library and not a
// tool. Also this may be turned into a stub to a CoffeeScript version for
// consistency.

var bbcode = require("./lib/bbcode");

var files = [];
for (var i = k = 2, ref = process.argv.length - 1; 2 <= ref ? k <= ref : k >= ref; i = 2 <= ref ? ++k : --k) {
  files.push(process.argv[i]);
}
var fs = require('fs');
files.forEach(function(f) {
  console.log("Reading %s...", f);
  return process.stdout.write(bbcode(fs.readFileSync(f)));
});

#!/usr/bin/env node

// Simply stub for running the BBCode parser over input files to translate into
// BBCode.

var bbcode = require("./bbcode");

var files = [];
for (var i = k = 2, ref = process.argv.length - 1; 2 <= ref ? k <= ref : k >= ref; i = 2 <= ref ? ++k : --k) {
  files.push(process.argv[i]);
}
var fs = require('fs');
files.forEach(function(f) {
  console.log("Reading %s...", f);
  return process.stdout.write(bbcode.bbcode(fs.readFileSync(f)));
});

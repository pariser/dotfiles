#! /usr/bin/env node

var fs = require('fs');

var _ = require('underscore');
var async = require('async');
var path = require('path');
var program = require('commander');
var sourceMap = require('source-map');

program
  .version('0.0.1')
  .option('-f, --file [file]', 'file')
  .option('-l, --line <line>', 'line number', parseInt)
  .option('-c, --column <column>', 'column number', parseInt)
  .option('-m, --source-map <source-map>', 'source map')
  .option('-d, --direction [direction]', 'direction: "original" (default) or "generated"', String, 'original')
  .parse(process.argv);;

async.waterfall([
  function(cb) {
    if (!_.isNumber(program.line)) {
      return cb('Line number required');
    }
    if (!_.isNumber(program.column)) {
      return cb('Column number required');
    }
    if (program.direction !== 'original' && program.direction !== 'generated') {
      return cb('Expected direction: "original" or "generated"');
    }
    cb();
  },
  function(cb) {
    if (typeof program.file !== 'undefined' &&
        typeof program.sourceMap === 'undefined' &&
       program.direction === 'original') {
      fs.readFile(program.file, 'utf8', function(err, data) {
        if (err) {
          cb('Could not read file ' + program.file);
        }

        var match = data.match(/\/\/\# sourceMappingURL=(.+)$/);
        if (match && match[1]) {
          program.sourceMap = path.basename(match[1]);
        }
        cb();
      });
    } else {
      cb();
    }
  },
  function(cb) {
    if (typeof program.sourceMap === 'undefined') {
      return cb('Source Map required');
    }
    cb();
  },
  function(cb) {
    if (program.direction === 'generated' && typeof program.file === 'undefined') {
      return cb('File required when requesting "generated" position');
    }
    cb();
  },
  function(cb) {
    var dir = path.dirname(program.file) || path.dirname(program.sourceMap);
    process.chdir(dir);
    cb();
  },
  function(cb) {
    fs.readFile(program.sourceMap, 'utf8', function(err, data) {
      if (err) {
        return cb('Could not read source map ' + program.sourceMap + ', error: ' + err.toString());
      }
      var sourceMapConsumer = new sourceMap.SourceMapConsumer(data);

      if (program.direction === 'generated') {
        cb(null, sourceMapConsumer.generatedPositionFor({
          line: program.line,
          column: program.column,
          source: program.file
        }));
      } else {
        cb(null, sourceMapConsumer.originalPositionFor({
          line: program.line,
          column: program.column
        }));
      }
    });
  },
  function(sourceInfo, cb) {
    var data = _.extend({ status: 'success' }, sourceInfo);
    data.source = path.basename(data.source);

    console.log(JSON.stringify(data));
    cb();
  }
], function(err) {
  if (err) {
    console.error({ status: 'error', error: err.toString() });
    return program.help();
  }
});

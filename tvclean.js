#!/usr/bin/env node

var futil = require('fsutil')
	, fs = require('fs')
	, util = require('util')
	, YAML = require('js-yaml')
	, Utils = require('./utils')
	, system = require('exec-sync')
	, program = options = require('commander')
	, _ = require('lodash')
	, config = require(Utils.userHome()+"/tvclean_config.yml")
	, glob = require('glob')
	, PATH = require('path');
 

program
	.version('0.0.1')
	.option('-m, --message [msg]','Message to send')
	.parse(process.argv);

var app = {
	clean: function () {
		process.chdir(config.tv_dir);
		showsToWork = scrape();
		console.log(showsToWork);
		//_.forEach(showsToWork, function (show) {
			//var toDel = getDeletions(show);
		//});
	}
}

var scrape = function () {
	var shows = filtered = glob.sync('*');

	_.forEach(config.ignores, function (ignore) {
		var regex = new RegExp(ignore,'i');
		filtered = _.reject(filtered, function (item) {
			return regex.test(item);
		});
	});

	return _.map(filtered, function (show) {
		var result;
		show = PATH.resolve(show);
		chdir(show, function () {
			var videoFiles = glob.sync('**');
			videoFiles = _.reject(videoFiles, function (file) {
				if (!Utils.isFile(file)) return true;
				return Utils.fileSize(file) < (config.min_media_size*1024*1024);
			});

			result = {
				fullpath: show,
				name: PATH.basename(show),
				videoFiles: videoFiles
			};
		});
		return result;
	});
}

var getDeletions = function (show) {
	
}

var chdir = function (dir, fn) {
	var start = process.cwd();
	process.chdir(dir);
	fn();
	process.chdir(start);
}




// run
app.clean();

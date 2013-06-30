#!/usr/bin/env node

var fsutil = require('fsutil')
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
	.option('-l, --list',"List deletions, but don't delete")
	.parse(process.argv);

var app = {
	clean: function () {
		process.chdir(config.tv_dir);
		showsToWork = scrape();
		_.each(showsToWork, function (show) {
			var toDel = getDeletions(show);
			if (_.isEmpty(toDel)) return true; // continue
			console.log('%s extra episodes of %s',toDel.length,show.name);
			if (options.test) return true; // continue
			_.each(toDel, function (episode) {
				fsutil.rm(episode.fullpath);
			});
		});
	}
}

var scrape = function () {
	var shows = filtered = glob.sync('*');

	_.each(config.ignores, function (ignore) {
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

var getDeletions = function (tvshow) {
	var episodes = _.map(tvshow.videoFiles, function (episode){
		return new Episode(episode, tvshow);
	});
	episodes = _.sortBy(episodes, function (ep) {
		return -_.parseInt("".concat(ep.season,ep.episode));
	});
	return _.tail(episodes, 5);
}

var chdir = function (dir, fn) {
	var start = process.cwd();
	process.chdir(dir);
	fn();
	process.chdir(start);
}


var Episode = function (fullpath, tvshow) {
	var isValid = true;
	if (!/[Ss]\d{1,2}[Ee]\d{1,2}/i.test(fullpath)) {
		process.stderr(fullpath+" isn't named properly");
		isValid = false;
	}
	var season = _.parseInt(PATH.basename(fullpath).match(/([Ss])(\d{1,2})/)[2]);
	var episode = _.parseInt(PATH.basename(fullpath).match(/([Ee])(\d{1,2})/, 2)[2]);

	return {
		fullpath: tvshow.fullpath+'/'+fullpath,
		tvshow: tvshow.name,
		season: season,
		episode: episode,
		isValid: isValid
	};
}



// run
app.clean();

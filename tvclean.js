#!/usr/bin/env node

var fsutil = require('fsutil')
	, fs = require('fs')
	, util = require('util')
	, yaml = require('js-yaml')
	, utils = require('./utils')
	, system = require('exec-sync')
	, program = options = require('commander')
	, _ = require('lodash')
	, path = require('path')
	, glob = require('glob')
	, config;
 
CONFIG_FILE = path.join(utils.userHome(), "tvclean_config.yml");

program
	.version('0.0.1')
	.option('-l, --list',"List deletions, but don't delete")
	.parse(process.argv);

var clean = function () {
	process.chdir(config.tv_dir);
	_.each(scrape(), function (show) {
		var toDel = getDeletions(show);
		if (_.isEmpty(toDel)) return true; // continue
		console.log('%s extra episodes of %s', toDel.length, show.name);
		if (options.list) return true; // continue
		_.each(toDel, function (episode) {
			fsutil.rm(episode.fullpath);
		});
	});
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
		show = path.resolve(show);
		chdir(show, function () {
			var videoFiles = glob.sync('**');
			videoFiles = _.reject(videoFiles, function (file) {
				if (!utils.isFile(file)) return true;
				return utils.fileSize(file) < (config.min_media_size*1024*1024);
			});

			result = {
				fullpath: show,
				name: path.basename(show),
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
	var season = _.parseInt(path.basename(fullpath).match(/([Ss])(\d{1,2})/)[2]);
	var episode = _.parseInt(path.basename(fullpath).match(/([Ee])(\d{1,2})/, 2)[2]);

	return {
		fullpath: path.join(tvshow.fullpath,fullpath),
		tvshow: tvshow.name,
		season: season,
		episode: episode,
		isValid: isValid
	};
}

var createConfig = function () {
	var contents = [
		"# Working directory",
		"tv_dir: '/path/to/tv shows'",
		"",
		"# The maximum amount of episodes to retain per show",
		"episodes_limit: 5",
		"",
		"# The minimum size in MB of files to consider",
		"min_media_size: 100",
		"",
		"# TV Shows to Ignore",
		"# these are regular expressions",
		"ignores:",
		"  - 'walking.*dead'",
		"  - 'vikings'"].join("\n");

	fs.writeFileSync(CONFIG_FILE, contents);
}

// load config
try {
	config = require(CONFIG_FILE);
} catch (e) {
	createConfig();
	throw 'Configuration is required. Modify ' + CONFIG_FILE + ' to configure';
} 

// run
clean();


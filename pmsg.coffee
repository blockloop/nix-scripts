#!/usr/bin/env coffee

require './utils.coffee'
push = require 'pushover-notifications'
system = require 'exec-sync'
program = require 'commander'
opts = program


p = new push(
  user: process.env["PUSHOVER_USER"]
  token: process.env["PUSHOVER_TOKEN"]
)

PRIORITY =
	low: -1
	normal: 0
	high: 1

program
  .version('0.0.1')
  .option('-m, --message [msg]','Message to send')
  .option('-t, --title [title]','Title of the message')
  .option('-n, --token [token]','Pushover Token to use (uses ENV["PUSHOVER_TOKEN"] or this)')
  .option('-u, --user [user]','Pushover user to send to (uses ENV["PUSHOVER_USER"] or this)')
	.option('-p, --priority [priority]',PRIORITY.keys())
  .parse process.argv

app =
	notify: (title,msg,priority_str,token,user) ->
		title ?= opts.title
		msg ?= opts.message
		priority_str ?= opts.priority or 'normal'
		p.token ?= token ?= opts.token
		p.user ?= user ?= opts.user
		throw 'Either pass token or set ENV["PUSHOVER_TOKEN"]' unless p.token
		throw 'Either pass user or set ENV["PUSHOVER_USER"]' unless p.user
		msg =
			title:title
			message:msg
			priority:PRIORITY[priority_str]

		p.send msg, (err, result) ->
			throw err if err
			console.log result

app.notify()


#!/usr/bin/env coffee

Object::keys = ->
  keys = []
  for i of this
    keys.push i  if @hasOwnProperty(i)
  keys


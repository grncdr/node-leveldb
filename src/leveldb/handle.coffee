{Batch} = binding = require '../../build/leveldb.node'
{Iterator} = require './iterator'

noop = ->

exports.open = (path, options, callback) ->
  if typeof options is 'function'
    callback = options
    options = null
  callback ?= noop
  binding.open path, options, (err, self) ->
    return callback err if err
    callback null, new Handle self

exports.openSync = (path, options) ->
  new Handle binding.open path, options

exports.destroy = (path, options, callback) ->
  if typeof options is 'function'
    callback = options
    options = null
  binding.destroy path, options, callback or noop

exports.destroySync = (path, options) ->
  binding.destroy path, options

exports.repair = (path, options, callback) ->
  if typeof options is 'function'
    callback = options
    options = null
  binding.repair path, options, callback or noop

exports.repairSync = (path, options) ->
  binding.repair path, options

class ReadHandle

  constructor: (@self) ->

  valid: -> @self.valid()

  close: (callback) -> @self.close(callback)
  closeSync: -> @self.close()

  get: (key, options, callback) ->
    if typeof options is 'function'
      callback = options
      options = null
    @self.get key, options, callback or noop


  getSync: (key, options) ->
    options = null if typeof options is 'function'
    @self.get key, options

exports.Handle = class Handle extends ReadHandle

  put: (key, value, options, callback) ->
    batch = new Batch
    batch.put key, value
    @write batch, options, callback

  putSync: (key, value, options) ->
    batch = new Batch
    batch.put key, value
    @writeSync batch, options

  del: (key, options, callback) ->
    batch = new Batch
    batch.del key
    @write batch, options, callback

  delSync: (key, options) ->
    batch = new Batch
    batch.del key
    @write batch, options

  write: (batch, options, callback) ->
    if typeof options is 'function'
      callback = options
      options = null
    @self.write batch, options, callback or noop

  writeSync: (batch, options) ->
    @self.write batch, options

  iterator: (options) ->
    @self.iterator options

  snapshot: (options) ->
    new ReadHandle @self.snapshot options

  property: (name) ->
    @self.property(name)

  approximateSizes: ->
    @self.approximateSizes.apply @self, arguments

  # TODO: compactRange

Throttle = require 'throttle'
{Transform, PassThrough} = require 'stream'
{WritableStreamBuffer} = require 'stream-buffers'
_  = require 'underscore'

exports.OFF = OFF = 0
exports.DROP = DROP = 1
exports.REJECT = REJECT = 2

class Stalled extends Transform
	constructor: () ->
		super()
		@buff = new WritableStreamBuffer
		@choke = false

	_transform: (chunk, encoding, done) ->
		if @choke
			@buff.write chunk
		else
			@push chunk
		
		done()

	enabled: (@choke) ->
		unless @choke then @push @buff.getContents()

class Latency extends Transform
	constructor: (@latency) ->
		super()

	_transform: (chunk, encoding, done) ->
		setTimeout () =>
			@push chunk
			done()
		, @latency

class Firewall extends Transform
	constructor: (options) ->
		super()
		
		{@mode, @sequence, @conn} = options

		if @disconnectAfter
			setTimeout () =>
				@disconnected = true
			, @disconnectAfter

	_transform: (chunk, encoding, done) ->
			if @mode is OFF
				@push chunk
				done()
			else
				if chunk.includes(@sequence)
					switch @mode
						when DROP
							return done()

						when REJECT
							@conn?.destroy?()
							return done()
				else
					@push chunk
					done()

class Conditioner extends PassThrough
	constructor: (options = {}) ->
		super()

		options = _.defaults options,
			latency: 50
			bps: 100
			firewall:
				mode: OFF
				sequence: ""
				conn: null

		firewall = new Firewall options.firewall
		throttle = new Throttle options.bps
		latency = new Latency options.latency
		@stalled = new Stalled()

		@on 'pipe', (source) ->
			source.unpipe @

			source = source.pipe firewall
			source = source.pipe throttle
			source = source.pipe latency
			source = source.pipe @stalled

			@transformStream = source

	pipe: (dest, options) ->
		@transformStream.pipe dest, options

	choke: (state) -> @stalled.enabled state

exports.Conditioner = Conditioner
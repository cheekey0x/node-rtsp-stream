child_process = require 'child_process'
util = require 'util'
events = require 'events'

Mpeg1Muxer = (options) ->
  self = @
  
  @url = options.url
  @ffmpegOptions = options.ffmpegOptions
  @exitCode = undefined

  @additionalFlags = []
  if @ffmpegOptions 
    for key of @ffmpegOptions
      @additionalFlags.push key
      @additionalFlags.push String(@ffmpegOptions[key]) unless String(@ffmpegOptions[key]) is ''

  @spawnOptions = [
    "-rtsp_transport"
    "tcp"
    "-i"
    @url
    '-f'
    'mpeg1video'
    # additional ffmpeg options go here
    @additionalFlags...
    '-'
  ]

  @stream = child_process.spawn "ffmpeg", @spawnOptions, {detached: false}

  @inputStreamStarted = true
  @stream.stdout.on 'data', (data) ->
    self.emit 'mpeg1data', data

  @stream.stderr.on 'data', (data) ->
    self.emit 'ffmpegStderr', data

  @stream.on 'exit', (code, signal) =>
    if code is 1
      console.error 'RTSP stream exited with error'
      @exitCode = 1
      @emit 'exitWithError'


  @

util.inherits Mpeg1Muxer, events.EventEmitter

module.exports = Mpeg1Muxer

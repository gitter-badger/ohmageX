@Ohmage.module "Components.Prompts", (Prompts, App, Backbone, Marionette, $, _) ->

  class Prompts.Video extends Prompts.Base
    template: "prompts/video"
    triggers: ->
      if App.device.isNative
        return {
          'click .input-activate .record-video': "record:video"
          'click .input-activate .from-library': "from:library"
        }

    initialize: ->
      super
      @listenTo @, "record:video", @recordVideo
      @listenTo @, "from:library", @fromLibrary
      @listenTo @model, "change:currentValue", @render

    recordVideo: ->
      # default to 10 minute capture length
      myDuration = if typeof @model.get('properties').get('max_seconds') isnt "undefined" then @model.get('properties').get('max_seconds') else App.custom.prompt_defaults.video.max_seconds

      navigator.device.capture.captureVideo ( (mediaFiles) =>
        # capture success
        # returns an array of media files
        # mediaFile properties: name, fullPath, type, lastModifiedDate, size (bytes)
        mediaFile = mediaFiles[0]

        if mediaFile.size > App.custom.prompt_defaults.video.caution_threshold_bytes
          App.execute "dialog:alert", "Caution: the recorded video is large, and may take a long time to upload to the server."

        @model.set 'currentValue',
          source: "capture"
          fileObj: mediaFile
          videoName: mediaFile.name
          UUID: _.guid()

      ),( (error) =>
        # capture error
        message = switch error.code
          when CaptureError.CAPTURE_INTERNAL_ERR
            "Camera failed to capture video."
          when CaptureError.CAPTURE_APPLICATION_BUSY
            "Camera is busy with another application."
          when CaptureError.CAPTURE_INVALID_ARGUMENT
            "Camera API Error."
          when CaptureError.CAPTURE_NO_MEDIA_FILES
            "No video captured."
          when CaptureError.CAPTURE_NOT_SUPPORTED
            "Video capture is not supported."

        App.execute "dialog:alert", "Unable to capture: #{message}"
        @model.set 'currentValue', false

      ),
        limit: 1,
        duration: myDuration

    fromLibrary: ->
      navigator.camera.getPicture ( (fileURI) =>
        # success callback

        window.resolveLocalFileSystemURL fileURI, ( (fileEntry) =>
          # success callback to convert the retrieved fileURI
          # into an actual useful File object rather than a string

          fileEntry.file (file) =>

            console.log 'file entry success'
            if file.size > App.custom.prompt_defaults.video.caution_threshold_bytes
              App.execute "dialog:alert", "Caution: the selected video is large, and may take a long time to upload to the server."

            @model.set 'currentValue',
              source: "library"
              fileObj: file
              videoName: fileURI.split('/').pop()
              UUID: _.guid()
              fileSize: file.size

        ),( (error) =>
          # error callback when reading the generated fileURI
          console.log 'file entry error'
          App.execute "dialog:alert", "Unable to read captured video file. #{JSON.stringify(error)}"
        )

      ),( (message) =>
        # error callback
        window.setTimeout (=>
          # setTimeout hack required to display alerts properly in iOS camera callbacks
          App.execute "dialog:alert", "Failed to get video from library: #{message}"
        ), 0
      ),
        destinationType: navigator.camera.DestinationType.FILE_URI
        mediaType: navigator.camera.MediaType.VIDEO
        sourceType: navigator.camera.PictureSourceType.PHOTOLIBRARY

    serializeData: ->
      data = @model.toJSON()
      myVideo = @model.get('currentValue')
      data.videoName = ""

      if myVideo then data.videoName = myVideo.videoName

      data.showSingleButton = !App.device.isNative
      data

    gatherResponses: (surveyId, stepId) =>
      response = @model.get('currentValue')
      @trigger "response:submit", response, surveyId, stepId

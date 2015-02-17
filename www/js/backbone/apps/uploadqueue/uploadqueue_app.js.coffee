@Ohmage.module "Uploadqueue", (Uploadqueue, App, Backbone, Marionette, $, _) ->

  class Uploadqueue.Router extends Marionette.AppRouter
    before: ->
      if !App.request("credentials:isloggedin")
        App.navigate Routes.default_route(), trigger: true
        return false
    appRoutes:
      "uploadqueue": "list"

  API =
    list: (campaign_id) ->
      App.vent.trigger "nav:choose", "queue"
      new Uploadqueue.List.Controller
    queueFailureGeneral: (responseData, errorPrefix, errorText, itemId) ->
      # show notice that it failed.
      console.log 'uploadqueue:upload:failure:campaign itemId', itemId

      App.execute "uploadqueue:item:error:set", itemId, "#{errorPrefix} #{errorText}"

      App.execute "notice:show",
        data:
          title: "Upload Failure"
          description: "Problem with Response: #{errorPrefix} #{errorText}"

  App.addInitializer ->
    new Uploadqueue.Router
      controller: API

  App.vent.on "upload:queue:start", (model) ->
    console.log 'test'

  App.vent.on "uploadqueue:list:stopped:clicked", (model) ->
    App.execute "notice:show",
      data:
        title: "Delete Response"
        description: "This response is unable to be uploaded. Delete it?"
        showCancel: true
      okListener: =>
        App.execute "uploadqueue:item:remove", model.get('id')

  App.vent.on "uploadqueue:list:running:clicked", (model) ->
    myId = model.get 'id'
    API.item myId
    App.navigate "uploadqueue/#{myId}"

  App.vent.on "uploadqueue:list:delete:clicked", (model) ->
    App.execute "notice:show",
      data:
        title: "Delete Response"
        description: "It's possible to try uploading this response again. Delete it anyway?"
        showCancel: true
      okListener: =>
        App.execute "uploadqueue:item:remove", model.get('id')

  App.vent.on "uploadqueue:list:upload:clicked", (model) ->
    console.log 'uploadqueue:list:upload:clicked model', model
    App.execute "uploader:new", 'uploadqueue', model.get('data'), model.get('id')

  App.vent.on "uploadqueue:upload:success", (response, itemId) ->
    # remove the uploaded item from the queue
    App.execute "uploadqueue:item:remove", itemId

  App.vent.on "uploadqueue:upload:failure:campaign", (responseData, errorText, itemId) ->
    API.queueFailureGeneral responseData, "Problem with Survey Campaign:", errorText, itemId

  App.vent.on "uploadqueue:upload:failure:response", (responseData, errorText, itemId) ->
    # placeholder for response errors handler.
    API.queueFailureGeneral responseData, "Problem with Survey Response:", errorText, itemId

  App.vent.on "uploadqueue:upload:failure:server", (responseData, errorText, itemId) ->
    # placeholder for server errors handler.
    API.queueFailureGeneral responseData, "Problem with Server:", errorText, itemId

  App.vent.on "uploadqueue:upload:failure:auth", (responseData, errorText, itemId) ->
    # placeholder for auth errors handler.
    API.queueFailureGeneral responseData, "Problem with Auth:", errorText, itemId

  App.vent.on "uploadqueue:upload:failure:network", (responseData, errorText, itemId) ->
    # placeholder for network errors handler.
    API.queueFailureGeneral responseData, "Problem with Network:", errorText, itemId


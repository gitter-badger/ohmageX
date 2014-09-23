@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Response Entity contains data related to the responses
  # within a given Survey.

  # currentResponses
  # "responses:init" initializes a ResponseCollection that persists in memory.
  # This collection is removed with "responses:destroy"
  currentResponses = false

  class Entities.Response extends Entities.Model
    defaults:
      response: "NOT_DISPLAYED" # All submitted responses are not_displayed by default.

  class Entities.ResponseCollection extends Entities.Collection
    model: Entities.Response

  API = 
    init: ($surveyXML) ->
      throw new Error "responses already initialized, use 'responses:destroy' to remove existing responses" unless currentResponses is false
      currentResponses = new Entities.ResponseCollection
      myResponses = @createResponses App.request("survey:xml:content", $surveyXML)
      currentResponses.add myResponses
      console.log 'currentResponses', currentResponses.toJSON()
    createResponses: ($contentXML) ->
      # first loop through all responses.
      # Only generate a new Response for a contentItem that actually
      # has a response, so we check its type. Currently a "message"
      # is the only item that does not have a response.

      # The .map() creates a new array, each key is object or false.
      # The .filter() removes the false keys.

      _.chain($contentXML.children()).map((child) ->
        $child = $(child)

        isResponseType = $child.tagText('promptType') isnt 'message'

        if isResponseType then {id: $child.tagText('id') } else false
      ).filter((result) -> !!result).value()


  App.commands.setHandler "responses:init", ($surveyXML) ->
    API.init $surveyXML
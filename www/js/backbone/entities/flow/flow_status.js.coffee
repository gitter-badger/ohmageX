@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The Flow Entity contains data related to the flow
  # of the Steps within a Survey.
  # This module contains the Status handlers for Flow.

  # References the current Flow StepCollection object, defined in flow_init.js.coffee
  # via the interface "flow:current"

  API =
    updateStatus: (currentStep, status) ->
      currentStep.set 'status', status
      console.log 'myStep', currentStep.toJSON()

  App.commands.setHandler "flow:status:update", (id, status) ->
    currentStep = App.request "flow:step", id
    API.updateStatus currentStep, status
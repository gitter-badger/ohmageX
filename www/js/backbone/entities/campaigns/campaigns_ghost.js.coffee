@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Campaigns Ghost handles all events dealing with campaign
  # Ghosted items.

  API =
    confirmRemove: (id, status) ->
      console.log 'confirmRemove'
      reason = switch status
        when 'ghost_outdated' then 'is out of date'
        when 'ghost_stopped' then 'is stopped'
        when 'ghost_nonexistent' then 'does not exist in the system'
        else throw new Error "Invalid campaign ghost state: #{status}"
      if window.confirm("This campaign #{reason}.\nRemove this campaign and any related survey responses?")
        App.execute "campaign:unsave", id

  App.commands.setHandler "campaign:ghost:remove", (id, status) ->
    API.confirmRemove id, status
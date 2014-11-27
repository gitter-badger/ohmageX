@Ohmage.module "Components.Navbutton", (Navbutton, App, Backbone, Marionette, $, _) ->

  # This Navbutton Selector returns a specific view, based on the
  # currently selected Nav button

  class Navbutton.SelectorController extends App.Controllers.Application
    initialize: (options) ->
      { navs, selected } = options

      @myView = @selectView navs, selected

      if @myView
        @listenTo @myView, "button:sync", (type) ->
          console.log "button:sync in Navbutton Component"
          App.execute "campaigns:sync"

        # Ensure this controller is removed during view cleanup.
        @listenTo @myView, "destroy", @destroy

    selectView: (navs, selected) ->
      switch selected
        when "Campaigns"
          return new Navbutton.Sync
            collection: navs
        when "Upload Queue"
          return new Navbutton.Upload
            collection: navs
        else
          return false

  App.reqres.setHandler "navbuttons:view", (navs) ->
    window.navs = navs
    selected = navs.findWhere({ chosen: true }).get('name')

    selector = new Navbutton.SelectorController
      navs: navs
      selected: selected

    selector.myView

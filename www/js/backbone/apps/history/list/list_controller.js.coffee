@Ohmage.module "HistoryApp.List", (List, App, Backbone, Marionette, $, _) ->

  # History List renders the history List view.

  class List.Controller extends App.Controllers.Application
    initialize: (options) ->

      @layout = @getLayoutView()
      campaigns = App.request "campaigns:saved:current"
      if campaigns.length isnt 0
        entries = App.request('history:entries:filtered', App.request("history:entries"))
        bucketsSelector = App.request "history:selector:buckets", App.request("history:entries")
        @buckets_filter = options.buckets_filter
        surveysSelector = App.request "history:selector:surveys", App.request("history:entries")

      @listenTo @layout, "show", =>
        if campaigns.length is 0
          @noticeRegion "No saved #{App.dictionary('pages','campaign')}! You must have saved #{App.dictionary('pages','campaign')} in order to view response history for them."
        else
          console.log "showing history layout"
          @bucketsRegion bucketsSelector, entries
          @surveysRegion surveysSelector, entries
          @listRegion entries

      if campaigns.length is 0
        loadConfig = false
      else
        loadConfig = entities: entries

      @show @layout, loading: loadConfig

    noticeRegion: (message) ->
      notice = new Backbone.Model message: message
      noticeView = @getNoticeView notice

      @show noticeView, region: @layout.noticeRegion

    bucketsRegion: (buckets, entries) ->
      @listenTo buckets, "change:chosen", (model) =>
        console.log 'change:chosen listener'
        # this listener must be in the controller,
        # any references to @entries inside of the selector
        # model are unable to trigger events or call methods
        # on @entries
        if model.isChosen()
          console.log 'model name to choose by', model.get('name')

          if model.get('name') is buckets.defaultLabel
            entries.trigger "filter:reset", 'bucket'
          else
            entries.trigger "filter:set", 'bucket', model.get('name')

      if @buckets_filter then buckets.chooseByName(@buckets_filter)

      bucketsView = @getFilterSelectorView 'bucket', buckets

      @show bucketsView, region: @layout.bucketsControlRegion

    surveysRegion: (surveys, entries) ->
      surveysView = @getFilterSelectorView 'survey_title', surveys

      @listenTo surveys, "change:chosen", (model) =>
        console.log 'change:chosen listener'
        # this listener must be in the controller,
        # any references to @entries inside of the selector
        # model are unable to trigger events or call methods
        # on @entries
        if model.isChosen()
          if model.get('name') is surveys.defaultLabel
            entries.trigger "filter:reset", 'survey_title'
          else
            entries.trigger "filter:set", 'survey_title', model.get('name')

      @show surveysView, region: @layout.surveysControlRegion


    listRegion: (responses) ->
      listView = @getListView responses

      @listenTo listView, "childview:clicked", (args) =>
        console.log 'childview:entry:clicked', args.model
        App.vent.trigger "history:list:entry:clicked", args.model

      @show listView, region: @layout.listRegion

    getLayoutView: ->
      new List.Layout

    getNoticeView: (notice) ->
      new List.Notice
        model: notice

    getFilterSelectorView: (filterType, collection) ->
      new List.FilterSelector
        filterType: filterType
        collection: collection

    getListView: (entries) ->
      new List.Entries
        collection: entries

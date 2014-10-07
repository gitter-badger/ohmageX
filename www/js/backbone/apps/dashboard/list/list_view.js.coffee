@Ohmage.module "DashboardApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.Survey extends App.Views.ItemView
    tagName: 'li'
    template: "dashboard/list/survey_item"
    triggers:
      "click": "survey:clicked"

  class List.Surveys extends App.Views.CompositeView
    template: "dashboard/list/surveys"
    itemView: List.Survey
    itemViewContainer: ".surveys"

  class List.Layout extends App.Views.Layout
    template: "dashboard/list/list_layout"
    regions:
      listRegion: "#list-region"
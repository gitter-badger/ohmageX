@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The History Buckets Entity manages the user History selector containing
  # unique buckets

  currentBuckets = false

  class Entities.UserHistoryBucketsNav extends Entities.UserHistorySelectorNav


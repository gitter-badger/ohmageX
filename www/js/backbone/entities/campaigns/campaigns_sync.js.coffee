@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # The campaignsSync ensures that proper campaign data is loaded
  # in the proper sequence for syncing between CampaignsUser, CampaignsVisible,
  # and CampaignsSaved.

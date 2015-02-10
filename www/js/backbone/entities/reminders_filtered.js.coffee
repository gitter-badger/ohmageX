@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

  # Reminders Filter entity.
  # methods for fetching reminder based on filter criteria.

  API =

    todayHourMinute: (myMoment) ->
      input = moment(myMoment)

      hour = input.hour()
      minute = input.minute()
      second = input.second()

      moment().startOf('day').hour(hour).minute(minute).second(second)


    surveyScheduledLaterToday: (reminders, surveyId) ->
      now = moment()
      dayEnd = moment(now).endOf('day')

      reminders.filter (reminder) =>
        activationDate = reminder.get('activationDate')
        todayHourMinute = @todayHourMinute activationDate

        # active reminders only.
        if !reminder.get('active') then return false
        console.log 'passed active'
        # ensure the reminder matches the survey ID.
        if reminder.get('surveyId') isnt surveyId then return false
        console.log 'passed survey ID match'

        # for all cases:
        # verify the hour and minute of this activationDate
        # is later than now.
        # daily reminders will pass the filter if this is true.
        if now > todayHourMinute then return false
        console.log 'passed hour minute later than now'

        if !reminder.get('repeat')
          # reminder is non-repeating
          # check the activationDate of this specific reminder
          # occurring later today.
          # only passes if:
          # now < activationDate < dayEnd
          if !(now < activationDate and activationDate < dayEnd) then return false
          console.log 'non-repeating, passed now < activationDate < dayEnd'
        else if reminder.get('repeatDays').length isnt 7
          # reminder is a collection of "weekly" notifications
          # must make sure that today is in the collection of repeatDays.
          # note type conversion of now.day() to string for comparison.
          if !("#{now.day()}" in reminder.get('repeatDays')) then return false
          console.log 'repeating weekly-ish, passed today is in repeatDays'

        return true

  App.reqres.setHandler "reminders:survey:scheduled:latertoday", (surveyId) ->
    reminders = App.request "reminders:current"
    new Entities.Reminders API.surveyScheduledLaterToday(reminders, surveyId)
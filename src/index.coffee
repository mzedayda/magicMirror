angular.module('magicMirror',['angularMoment', 'gapi'])
	.value('GoogleApp', {
		apiKey: 'AIzaSyBfqIoc4HHaCLhs4SzCQARpmshg2qeKYtY'
		clientId: '532617458069-u3ejhlpj99smmdshbb7maera4traa68d.apps.googleusercontent.com'
		scopes: 'https://www.googleapis.com/auth/calendar.readonly'
	})
	.filter('toArray', () ->
		return (items) ->
			filtered = []
			angular.forEach items, (item) ->
				filtered.push item
			filtered
	)
	.controller 'eventsCtrl', ($scope, GAPI, Calendar) ->
		$scope.authorize = (callback) ->
			GAPI.init().then callback

		minutes = 1000 * 60
		hours = 60 * minutes
		updateInterval = 10 * minutes

		today = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
		yesterday = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()-1).toISOString()	
		tomorrow = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()+2).toISOString()

		$scope.events = {}
		$scope.getEvents = () ->
			$scope.authorize () ->
				Calendar.listCalendarList().then (calendarList) ->
					for calendar in calendarList.items
						Calendar.listEvents({
							calendarId: calendar.id
							singleEvents: true 
							timeMin: yesterday()
							timeMax: tomorrow()
						}).then (eventList) ->
							for event in eventList.items
								$scope.events[event.id] = event

		$scope.getEvents()
		setInterval $scope.getEvents, updateInterval
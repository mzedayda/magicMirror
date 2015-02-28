angular.module('magicMirror',['angularMoment', 'gapi', 'angular-skycons'])
	.value('GoogleApp', {
		apiKey: 'AIzaSyBfqIoc4HHaCLhs4SzCQARpmshg2qeKYtY'
		clientId: '532617458069-u3ejhlpj99smmdshbb7maera4traa68d.apps.googleusercontent.com'
		scopes: 'https://www.googleapis.com/auth/calendar.readonly'
	})
	.value('TIME', {seconds: 1000, minutes: 60*1000, hours: 60*60*1000, days: 24*60*60*1000})
	.run( (amMoment) ->
		moment.locale 'he',
			calendar:
				sameDay : '[היום,] LT'
				nextDay : '[מחר,] LT'
				nextWeek : 'dddd[,] LT'
				lastDay : '[אתמול,] LT'
				sameElse : 'L'
	)
	.filter('toArray', () ->
		return (items) ->
			filtered = []
			angular.forEach items, (item) ->
				filtered.push item
			filtered
	)
	.filter('floor', () ->
		return (number) ->
			Math.floor number
	)
	.controller('eventsCtrl', (TIME, $scope, GAPI, Calendar) ->
		$scope.authorize = (callback) ->
			GAPI.init().then callback

		today = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString()
		yesterday = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()-1).toISOString()	
		tomorrow = () ->
			now = new Date();
			return new Date(now.getFullYear(), now.getMonth(), now.getDate()+6).toISOString()

		$scope.events = {}
		$scope.getEvents = () ->
			$scope.authorize () ->
				Calendar.listCalendarList().then (calendarList) ->
					for calendar in calendarList.items
						Calendar.listEvents({
							calendarId: calendar.id
							singleEvents: true 
							timeMin: today()
							timeMax: tomorrow()
						}).then (eventList) ->
							for event in eventList.items
								$scope.events[event.id] = event

		$scope.getEvents()
		setInterval $scope.getEvents, 3 * TIME.hours
	)
	.controller('weatherCtrl', (TIME, $scope, $http) ->
		$scope.styles = [
			{color:"#DDD"}
			{color:"#CCC"}
			{color:"#AAA"}
			{color:"#999"}
			{color:"#888"}
			{color:"#666"}
			{color:"#444"}
			{color:"#222"}
		]
		$scope.getWeatherData = () ->
			$http.get('/weather').success (response) ->
				$scope.currentWeather = response.currently
				$scope.dailyForecast = response.daily.data

		$scope.getWeatherData()
		setInterval $scope.getWeatherData, 12 * TIME.hours
	)
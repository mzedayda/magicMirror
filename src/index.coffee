angular.module('magicMirror',['angularMoment', 'angular-skycons'])
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
	.controller('eventsCtrl', (TIME, $scope, $http) ->
		$scope.events = {}
		$scope.login = (next) ->
			$http.get('/authUrl').success (authUrl) ->
				console.log authUrl
				win = window.open authUrl, "login & authorize", 'width=800, height=400'
				authCodePoll = window.setInterval () ->
					url = win.document.URL
					unless url.indexOf('n100.example.com') is -1
						window.clearInterval authCodePoll
						index = url.indexOf 'code='
						authCode = url[index+5..url.length]
						win.close()
						next authCode
				, 200
		$scope.getEvents = () ->
			$scope.login (authCode) ->
				console.log authCode
				$http.get("/events?authCode=#{authCode}").success (events) ->
					for event in events
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
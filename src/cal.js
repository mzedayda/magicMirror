var clientId = '532617458069-u3ejhlpj99smmdshbb7maera4traa68d.apps.googleusercontent.com';

var apiKey = 'AIzaSyBfqIoc4HHaCLhs4SzCQARpmshg2qeKYtY';

var scopes = 'https://www.googleapis.com/auth/calendar.readonly';

function handleClientLoad() {
  gapi.client.setApiKey(apiKey);
  window.setTimeout(checkAuth,1);
}

function checkAuth() {
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: true}, handleAuthResult);
}

function handleAuthResult(authResult) {
  if (authResult && !authResult.error) {
    makeApiCall();
  } else {
    window.setTimeout(handleAuthClick, 100);
  }
}

function handleAuthClick(event) {
  gapi.auth.authorize({client_id: clientId, scope: scopes, immediate: false}, handleAuthResult);
}

function today() {
  date = new Date();
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function tomorrow() {
  // Not good, should be replaced
  date = new Date();
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);
}

function insertRow(event) {
  var docEvents = document.getElementById('events');
  var tableRow = document.createElement('tr');
  var eventTime = document.createElement('td');
  startHour = moment(new Date(event.start.dateTime || event.start.date)).format("HH:mm");
  eventTime.appendChild(document.createTextNode(startHour));
  eventTime.setAttribute("class", "eventTime small");
  var eventTitle = document.createElement('td');
  eventTitle.appendChild(document.createTextNode(event.summary));
  eventTitle.setAttribute("class", "eventTitle xxsmall");
  tableRow.appendChild(eventTitle);
  tableRow.appendChild(eventTime);
  docEvents.appendChild(tableRow);
}

function makeApiCall() {
  gapi.client.load('calendar', 'v3').then(function() {
    function getTodayEvents() {
      console.log("Called");
      var request = gapi.client.calendar.calendarList.list();
      request.then(function(resp) {
        resp.result.items.forEach(function(calendar) {
          min = today().toISOString();
          max = tomorrow().toISOString();
          var eventsRequest = gapi.client.calendar.events.list({calendarId: calendar.id, singleEvents: true, timeMin: min, timeMax: max});
          eventsRequest.then(function (resp2) {
            resp2.result.items.forEach(function(event) {
              insertRow(event);
            });
          }, function(reason) {
            console.log('Error: ' + reason.result.error.message);
          });
        });
      }, function(reason) {
        console.log('Error: ' + reason.result.error.message);
      });  
      setTimeout(getTodayEvents, 6000000);   
    }
    getTodayEvents();
  });
}
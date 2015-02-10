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

function makeApiCall() {
  gapi.client.load('calendar', 'v3').then(function() {
    var request = gapi.client.calendar.calendarList.list();
    request.then(function(resp) {
      var section = document.createElement('section');
      resp.result.items.forEach(function(calendar) {
        section.appendChild(document.createTextNode(calendar.id + " \n"));
      });
      document.getElementById('events').appendChild(section);
    }, function(reason) {
      console.log('Error: ' + reason.result.error.message);
    });
  });
}
function handler(event) {
  var request = event.request;

  if (event.viewer.ip !== '%ALLOWED_IP%') {
    return {
      statusCode: 503,
      statusDescription: 'Service Unavailable',
      body: '<html><body><h1>503 Service Unavailable</h1><p>Sorry, we are currently down for maintenance. Please check back later.</p></body></html>'
    };
  }
  
  return request;
}

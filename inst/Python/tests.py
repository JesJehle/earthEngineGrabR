
import ee



print 'Visit the URL below in a browser to authorize'
print '%s?client_id=%s&redirect_uri=%s&scope=%s&response_type=code' % \
  ('https://accounts.google.com/o/oauth2/auth',
  client_id,
  redirect_uri,
  'https://www.googleapis.com/auth/fusiontables')

#4. Google redirects the user back to your web application and
#   returns an authorization code
auth_code = raw_input('Enter authorization code (parameter of URL): ')

#5. Your application requests an access token and refresh token from Google
data = urllib.urlencode({
  'code': auth_code,
  'client_id': client_id,
  'client_secret': client_secret,
  'redirect_uri': redirect_uri,
  'grant_type': 'authorization_code'
})


request = urllib2.Request(
  url='https://accounts.google.com/o/oauth2/token',
  data=data)
request_open = urllib2.urlopen(request)

#6. Google returns access token, refresh token, and expiration of
#   access token
response = request_open.read()


import webbrowser
import urllib
import urllib2
import gdal

client_id = "313069417367-efu6s6pldp8pbf86il3grjdv8kpgp5d4.apps.googleusercontent.com"
client_secret =  "9sKMt27c8uQprUja2y5Mk4o_"
ft_scope = "https://www.googleapis.com/auth/fusiontables"
authorize = "https://accounts.google.com/o/oauth2/auth"
access = "https://accounts.google.com/o/oauth2/token"
# redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
# redirect_uri = "http://localhost"
redirect_uri = "http://localhost:1410/"

#ft_auth_url = gdal.GOA2GetAuthorizationURL(ft_scope)
#print(ft_auth_url)

# webbrowser.open("https://accounts.google.com/o/oauth2/auth", "response_type=code")

authorisation_url = 'https://accounts.google.com/o/oauth2/auth?' + urllib.urlencode({
      'client_id': client_id,
      'scope': ft_scope,
      'redirect_uri': redirect_uri,
      'response_type': 'code',
})


webbrowser.open_new(authorisation_url)

auth_code = raw_input('Enter code here: ')

#auth_code = "4/VgAQUn_aLn6xsTTyhQB7iDF7e4zjM7AonRXjw58lqL4Z8qpHR4uOT0A"

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
pirnt(request_open)



#def get_ft_auth_tokens:








#import json
#import os
#from osgeo import ogr
#from osgeo import gdal


#config_path = os.path.expanduser('~/.config/earthengine/ft_credentials.json')
#refresh_token = json.load(open(config_path))['refresh_token']
#ft_driver = ogr.GetDriverByName('GFT')
#dst_ds = ft_driver.Open('GFT:refresh=' + refresh_token, True)
#dst_layer = dst_ds.GetLayerByName("mike_bnd_af")
#print(dst_layer.GetStyleTable())


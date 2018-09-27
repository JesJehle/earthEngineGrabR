import ee
from ee.cli import commands
import webbrowser
from osgeo import gdal
import urllib
from ee.oauth import get_credentials_path
import json

ft_scope = 'https://www.googleapis.com/auth/fusiontables'


def request_ee_code():
    # get authorisation url
    auth_url = ee.oauth.get_authorization_url()
    # call auth_url in browser to grand access by the user
    webbrowser.open_new(auth_url)

def request_ee_token(auth_code):
    token = ee.oauth.request_token(auth_code)
    ee.oauth.write_token(token)
    print('\nSuccessfully saved ee authorization token.')


def request_ft_code():
    ft_auth_url = gdal.GOA2GetAuthorizationURL(ft_scope)
    webbrowser.open(ft_auth_url)


def request_ft_token(auth_code):
    refresh_token = gdal.GOA2GetRefreshToken(auth_code, ft_scope)
    ft_credentials_name = "ft_credentials.json"
    path_credentials = get_credentials_path()
    ft_credentials_path = path_credentials.replace('credentials', ft_credentials_name)
    ft_credentials = {'refresh_token': refresh_token}
    with open(ft_credentials_path, 'w') as outfile:
        json.dump(ft_credentials, outfile)#

    print('\nSuccessfully saved ft authorization token.')



# test
#request_ee_code()
#code = raw_input("Enter Code here: ")
#request_ee_token(code)



__author__ = 'yang'

import requests
from getpass import *
import urllib
from requests_oauthlib import OAuth2Session
import time
import os
import ee


os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'

ee.Initialize()

# Define URLs
google_accounts_url = 'https://accounts.google.com'
authentication_url = 'https://accounts.google.com/ServiceLoginAuth'

appspot_url = 'https://ee-api.appspot.com/assets/upload/geturl?'

#session = requests.session()

#r = session.get(google_accounts_url)

#auto = r.headers.get('X-Auto-Login')
#follow_up = urllib.unquote(urllib.unquote(auto)).split('continue=')[-1]
#galx = r.cookies['GALX']
#print session.get(google_accounts_url)









def google_authenticate(username, password):
    '''
    construct a request session using google account to communicate with ee-api.appspot.com
    '''
    session = requests.session()

    r = session.get(google_accounts_url)

    auto = r.headers.get('X-Auto-Login')
    follow_up = urllib.unquote(urllib.unquote(auto)).split('continue=')[-1]
    galx = r.cookies['GALX']

    # authenticate user
    data = {
        'continue': follow_up,
        'Email': username,
        'Passwd': password,
        'GALX': galx
    }

    r = session.post(authentication_url, data=data)

    if r.url != authentication_url:
        return session
    else:
        return None

def get_uploadUrl(session):
    '''
    get the GEE asset upload url
    '''
    r = google.get(appspot_url)
    return r.json()['url']

def upload_file(session, file_path, asset_name):
    '''
    upload a single file to GEE, but without ingestion
    :param session:
    :param file_path:
    :return:
    '''
    files = {'file': open(file_path, 'rb')}
    uploadurl = get_uploadUrl(session)

    r = session.post(uploadurl, files=files)

    gsid = r.json()[0]
    asset_data = {"id": asset_name,
                  "tilesets": [
                      {"sources": [
                          {"primaryPath": gsid,
                           "additionalPaths": []}
                      ]}
                  ],
                  "bands": [],
                  "reductionPolicy": "MEAN"}
    return asset_data

def get_geeSession():
    '''
    construct gee oauth2 session using automatic refresh token
    :return:
    '''
    gee = OAuth2Session(client_id, token=token, auto_refresh_url=token_url, auto_refresh_kwargs=extra)

    return gee

def get_geeTaskId(session):
    r = session.post('https://earthengine.googleapis.com/api/newtaskid')
    return r

####################################
#   Main Section
####################################

#username = raw_input('User name (gmail): ')
#password = getpass('Password: ')

username = 'jesjehle'
password = 'janusch@arbeit'


google = google_authenticate(username, password)

print 'Authenticated'

#ASSET folder or collection name
asset_dir = 'users/yang/test/%s'

#Local file path
img = '/Users/yang/model/model_2100.tif'

print 'uploading file'
asset_request = upload_file(google, img, asset_dir % 'model2100')

taskid = ee.data.newTaskId(1)[0]
ret = ee.data.startIngestion(taskid, asset_request)

print 'ingesting started'
import ee
from ee.cli import commands
import webbrowser
import urllib
from ee.oauth import get_credentials_path
import json
import os
import base64
import hashlib

ft_scope = 'https://www.googleapis.com/auth/fusiontables'


def request_ee_code():
    out = create_codes()
    code_verifier = out[0]
    code_challenge = out[1]
     # get authorisation url
    auth_url = ee.oauth.get_authorization_url(code_challenge)
    # call auth_url in browser to grand access by the user
    webbrowser.open_new(auth_url)
    return code_verifier

def request_ee_token(auth_code, code_verifier):
    token = ee.oauth.request_token(auth_code, code_verifier)
    ee.oauth.write_token(token)

    
def _base64param(byte_string):
  """Encodes bytes for use as a URL parameter."""
  return base64.urlsafe_b64encode(byte_string).rstrip(b'=')
  
def create_codes():
  code_verifier = _base64param(os.urandom(32))
  code_challenge = _base64param(hashlib.sha256(code_verifier).digest())
  return code_verifier, code_challenge








import ee
import getpass
import subprocess

subprocess.call("earthengine authenticate")

password = getpass.getpass()

print password

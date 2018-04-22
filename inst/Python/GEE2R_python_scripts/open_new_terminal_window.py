
filename = "gdal_auth_gee2r.py"


from sys import executable
from subprocess import Popen, CREATE_NEW_CONSOLE

Popen([executable, 'script.py'], creationflags=CREATE_NEW_CONSOLE)

input('Enter to exit from this launcher script...')
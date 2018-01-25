from setuptools import setup

setup(name='GEE2R',
      version='0.1',
      description='integration of R and the Google Earth Engine',
      url='https://github.com/JesJehle/GEE2R',
      author='Janusch Jehle',
      author_email='JesJehle@gmx.de',
      license='MIT',
      packages=['GEE2R'],
      install_requires=[
          'google-api-python-client',
          'pyCrypto',
          'earthengine-api'],
      zip_safe=False)


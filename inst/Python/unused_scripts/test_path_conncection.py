#!/usr/bin/env python
import os
from pandas import read_csv as read


    # save token
    # load system params from R

path_credentials = read("path.csv", delimiter=',').columns.values[0]

print(path_credentials)

filename = 'token.txt'
real_path = os.path.abspath(__file__)
folder_path= os.path.dirname(real_path)

print(os.path.join(folder_path, filename))




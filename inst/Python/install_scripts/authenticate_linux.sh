#!/bin/sh

gnome-terminal -x sh -c "earthengine authenticate | tee ~/outputfile.txt; bash" 



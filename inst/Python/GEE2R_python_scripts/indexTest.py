
import pandas as pd
import csv


df = pd.read_csv("connection.csv", delimiter=',')

# print df

if "modis_treeCover" in df:
    print "blub"

print df.columns


print df["chirps_precipitation"][1]
print df["jrc_distanceToWater"][1]
print df["modis_treeCover"][1]
print df["modis_nonTreeVegetation"][1]
print df["modis_nonVegetated"][1]
print df["srtm_slope"][1]
print df["modis_quality"][1]
print df["oxford_friction"][1]
print df["oxford_accessibility"][1]
print df["assetPath"][1]
print df["spatialReducer"][1]
print df["resolution"][1]
print df["name"][1]
print df["year_start"][1]
print df["year_end"][1]








#with open("connection.json") as json_data:
#    d = json.load(json_data)






#print df.columns

#print df




#print df.loc[0,2]


#with open("conection.csv") as csvfile:
#    readCSV = csv.reader(csvfile, delimiter=',')
#    for i in readCSV:
#        print i



#vec = ["get_data.py", "2000", "2000", "stripes", "mean" ,"100", "GeoJSON", "example" ,"chirps_precipitation" ,"mean" ,"mean" ,"jrc_permanentWater", "mean",  "mean", "modis_treeCover", "mean", "mean", "modis_nonTreeVegetation", "mean", "mean", "modis_nonVegetated", "mean", "mean", "srtm_elevation", "mean", "mean", "srtm_slope", "mean", "mean", "modis_quality", "mean"," mean"]
#print vec

#print vec.index("chirps_precipitation") + 1





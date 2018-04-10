
import ee

ee.Initialize()

tableFT = ee.FeatureCollection('ft:1ROTDNcKnTtP-9nJXF2G4w0dXNbpMeKm38bEitA5k')
 #chirps

chirps_image = ee.ImageCollection("UCSB-CHG/CHIRPS/PENTAD")\
    .filter(ee.Filter.calendarRange(2008, 2010, 'year'))\
    .filter(ee.Filter.calendarRange(1, 12, 'month'))\
    .reduce(ee.Reducer.mean())\
    .rename('bla')


chirps_featureColleciton = chirps_image\
    .reduceRegions(tableFT, ee.Reducer.mean().setOutputs(['blub']), 100)





task = ee.batch.Export.table.toDrive(
        collection=chirps_featureColleciton,
        description=str("vectorsToDriveExample"),
        fileFormat = str("GeoJSON"),
        folder = "GEE2R_temp")

task.start()


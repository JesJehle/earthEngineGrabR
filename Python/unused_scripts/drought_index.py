import ee
# Initialize the Earth Engine object, using the authentication credentials.


ee.Initialize()

chirps = ee.ImageCollection('UCSB-CHG/CHIRPS/PENTAD')

startyear = 1985
endyear = 2015

# create list for years
years = range(startyear, endyear)

# make a list with months
months = range(1, 12)
print months

# Set date in ee date format
startdate = ee.Date.fromYMD(startyear, 1, 1)
enddate = ee.Date.fromYMD(endyear + 1, 12, 31)

# Filter chirps
Pchirps = chirps.filterDate(startdate, enddate).sort('system:time_start', False).select("precipitation")

# Define geograpic domain
area = ee.Geometry.Rectangle(-20.0, 20.0, 20, 20.0)


# calculate the monthly mean
def calcMonthlyMean(imageCollection):
    mylist = ee.List([])
    for y in years:
        for m in months:
            w = imageCollection.filter(ee.Filter.calendarRange(y, y, 'year')).filter(
                ee.Filter.calendarRange(m, m, 'month')).sum();
            mylist = mylist.add(
                w.set('year', y).set('month', m).set('date', ee.Date.fromYMD(y, m, 1)).set('system:time_start',
                                                                                           ee.Date.fromYMD(y, m, 1)))
    return ee.ImageCollection.fromImages(mylist)


# run the calcMonthlyMean function
monthlyChirps = ee.ImageCollection(calcMonthlyMean(Pchirps))

print monthlyChirps.getInfo()
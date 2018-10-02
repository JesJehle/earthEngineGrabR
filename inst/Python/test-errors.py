import ee

ee.Initialize()

data = ee.ImageCollection("UCSB-CHG/CHIRPS/DAILY")

filtered = data.filterDate("1950-05-01", "1953-05-01")

start = "lkjl"
end = "lkjasdf"

print(filtered.getInfo())
print(filtered.size().getInfo())

if filtered.size().getInfo() == 0:
    raise ValueError("With " + start + " to " + end)

import ee








spatial_reducer = "mean"
names = ["landcover", "quality"]

new_names = [n + "_" + spatial_reducer for n in names]
print(new_names)
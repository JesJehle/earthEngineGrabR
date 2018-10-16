
# The earthEngineGrabR Workflow

* **Search** for dataset in Earth Engine [Data Catalog](https://developers.google.com/earth-engine/datasets/) .

* **Grab** data according to a user defines data reuquest.

#### Search for data

Use Earth Engine's [Data Catalog](https://developers.google.com/earth-engine/datasets/) to browse and find datasets you want to grab using the earthEngineGrabR. Once you have found a dataset, use the snippet section to obtain the **dataset ID** and whether the dataset is an **image** or a **collection of images**. The snippet section consists of one line of code (don't open the link) and shows how Earth Engine loads the dataset. If it is an image, the `ee.Image(dataset-ID)` constructor is used. if it is a collection the `ee.ImageCollection(dataset-id)` constructor is used instead.

#### Grab data

`ee_grab()` requests and imports data from Earth Engine to R. `ee_grab()` takes two arguments, `data` and `targetArea`. `data` takes a single or a list of `ee_data_image()` and `ee_data_collection()` functions, which define the requested data to `ee_grab()`. If the requested data is an image use `ee_data_image()`, if it's a collection use `ee_data_collection()`. `targetArea` takes a path to a local geo-file, which defines the spatial target in which the data sould be aggregated.





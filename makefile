# Below is data processing
# Modeling data processing
data/all_data_processed.csv:data/all_data.csv
	Rscript scripts/prepare_all_data_for_modeling.R

data/all_data.csv:data/Taxis/taxi_data.csv
	Rscript scripts/merge_zillow_data_with_features.R

# Below is Taxi data processing
data/Taxis/taxi_data.csv:data/Taxis/pickle_files/taxi_data.pickle
	python scripts/combine_taxi_years.py

data/Taxis/pickle_files/taxi_data.pickle:data/Taxis/intermediate/yellow_tripdata_2015_sample.csv
	python scripts/process_taxi_data.py

data/Taxis/intermediate/yellow_tripdate_2010_sample.csv:data/Taxis/raw/yellow_tripdata_2010.csv
	sh scripts/get_random_taxi_samples.sh

data/NY_Info/zip_coords_dict.pickle:
	python scriptsbuild_NY_zip_coord_dict.py

# Below is Food Service Inspection data processing
data/FoodService/food_ins_grades.csv: scripts/process_food_inspection_results.py
	python scripts/process_food_inspection_results.py

data/FoodService/intermediate:
	mkdir data/FoodService/intermediate

# Below is recreation data processing
data/Recreation_Locations/recreation_location.csv: data/Recreation_Locations/intermediate
	python scripts/get_amenity_info_from_XML_files.py

data/Recreation_Locations/intermediate:
	mkdir data/Recreation_Locations/intermediate

# Below is liquor data processing
data/Liquor/liquor_licenses.csv: data/Liquor/intermediate/All_Licenses_v03.csv, scripts/process_liquor_results.R
	Rscript scripts/process_liquor_results.R

data/Liquor/intermediate/All_Licenses_v03.csv: data/Liquor/intermediate/All_Licenses_v02.csv
	Rscript scripts/merge_licenses_with_lat_long.R

data/Liquor/intermediate/All_Licenses_v02.csv: data/Liquor/intermediate/license_class_duration.csv
	Rscript scripts/merge_durations_with_licenses.R

data/Liquor/intermediate/license_class_duration.csv: data/Liquor/intermediate/All_Licenses.csv
	Rscript scripts/get_liquor_license_durations.R

data/Liquor/intermediate/All_Licenses.csv: data/Liquor/CSVs/10001.csv
	python scraping/combine_liquor_csv_files.py

data/Liquor/CSVs/10001.csv:
	python scraping/parse_scraped_liquor_data.py

# Below is Food Service Inspection data processing
data/FoodService/food_ins_grades.csv: data/FoodService/intermediate
	python scripts/process_food_inspection_results.py

data/FoodService/intermediate:
	mkdir data/FoodService/intermediate

# Below is recreation data processing
data/Recreation_Locations/recreation_location.csv: data/Recreation_Locations/intermediate
	python scripts/get_amenity_info_from_XML_files.py

data/Recreation_Locations/intermediate:
	mkdir data/Recreation_Locations/intermediate

# Below is liquor data processing
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

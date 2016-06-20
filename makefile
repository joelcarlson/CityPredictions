data/Liquor/intermediate/All_Licenses_with_issued_date.csv: data/Liquor/intermediate/license_class_duration.csv
	Rscript scripts/merge_durations_with_licenses.R

data/Liquor/intermediate/license_class_duration.csv: data/Liquor/intermediate/All_Licenses.csv
	Rscript scripts/get_liquor_license_durations.R

data/Liquor/intermediate/All_Licenses.csv: data/Liquor/CSVs/10001.csv
	python scraping/combine_liquor_csv_files.py

data/Liquor/CSVs/10001.csv:
	python scraping/parse_scraped_liquor_data.py

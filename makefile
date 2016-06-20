data/Liquor/license_class_duration.csv: data/Liquor/All_Licenses.csv
	Rscript scripts/get_liquor_license_durations.R

data/Liquor/All_Licenses.csv: Liquor_CSVs
	python scraping/combine_liquor_csv_files.py

Liquor_CSVs:
	python scraping/parse_scraped_liquor_data.py

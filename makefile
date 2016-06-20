data/Liquor/All_Licenses.csv: Liquor_CSVs
	python scraping/combine_liquor_csv_files.py

Liquor_CSVs:
	python scraping/parse_scraped_liquor_data.py

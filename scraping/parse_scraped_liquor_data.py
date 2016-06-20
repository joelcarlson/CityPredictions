import bs4
import sys
import os
from itertools import chain
from urllib import urlopen
import unicodecsv as csv


def read_and_parse_html(file_path):
    file_in = file_path
    page_source = urlopen(file_in).read().decode('utf-8')
    parsed_html = bs4.BeautifulSoup(page_source)
    return parsed_html


def get_table_from_parsed_html(parsed_html):
    tables = parsed_html.find_all('table')
    for sub_table in tables:
        if 'div' in sub_table.parent.name:
            result_table = sub_table.findAll("tr")
    return result_table


def get_row_vals(result_table, zipcode):
    ret = []
    print zipcode
    for row in result_table[1:]:
        row_vals = []
        ind = 0
        for col_val in row.find_all('td', class_='displayvalue'):
            ind += 1
            if ind == 2:
                row_vals.append(' '.join(col_val.text.lower().split()))
                continue
            print row_vals.append(col_val.text.rstrip().lower().strip())

        row_vals.append(row.a.get('href'))

        row_vals.append(zipcode)
        ret.append(row_vals)

    return ret


if __name__ == "__main__":
    # Run from top level
    html_files_path = 'data/Liquor/scraped_HTML_files/'
    CSV_output_path = 'data/Liquor/CSVs/'

    all_licenses = chain()
    for file_name in os.listdir(html_files_path):
        zipcode = file_name.split('.')[0]

        parsed_html = read_and_parse_html(html_files_path + file_name)
        result_table = get_table_from_parsed_html(parsed_html)
        results = get_row_vals(result_table, zipcode)

        #append
        all_licenses = chain(all_licenses, results)

        csv_name = '{}/{}.csv'.format(CSV_output_path, zipcode)
        with open(csv_name, 'wb') as f:
            writer = csv.writer(f)
            writer.writerows(list(all_licenses))

import bs4
import sys
import os
import time
from itertools import chain
from urllib import urlopen
import unicodecsv as csv
import contextlib


def read_and_parse_html(file_path):
    """
    read_and_parse_html

    Parameters
    ----------
    file_path : string
        path to html source file

    Returns
    -------
    parsed_html : bs4 soup object
        BeautifulSoup object for page source
    """

    file_in = file_path
    page_source = urlopen(file_in).read().decode('utf-8')
    parsed_html = bs4.BeautifulSoup(page_source)
    return parsed_html


def get_table_from_parsed_html(parsed_html):
    """
    get_table_from_parsed_html

    Parameters
    ----------
    parsed_html : bs4 soup object
        output from read_and_parse_html function

    Returns
    -------
    result_table: bs4 soup object
        BeautifulSoup object for table containing
        results of zipcode query
    """
    tables = parsed_html.find_all('table')
    for sub_table in tables:
        if 'div' in sub_table.parent.name:
            result_table = sub_table.findAll("tr")
    return result_table


def get_row_vals(result_table, zipcode):
    """
    get_row_vals

    Parameters
    ----------
    result_table : bs4 soup object
        output from get_table_from_parsed_html function
    zipcode : string
        a string containing the zipcode used to query the SLA database

    Returns
    -------
    ret: list
        the extracted liquor license data from a single zipcode
    """
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


# The class and context
class DummyFile(object):
    def write(self, x): pass

@contextlib.contextmanager
def nostdout():
    save_stdout = sys.stdout
    sys.stdout = DummyFile()
    yield
    sys.stdout = save_stdout


if __name__ == "__main__":
    start_time = time.time()
    print "Extracting query data from NY SLA HTML source files"
    print "Extracted data from: "
    # Run from top level, save each zip into an individual CSV
    html_files_path = 'data/Liquor/scraped_HTML_files/'
    CSV_output_path = 'data/Liquor/CSVs/'

    all_licenses = chain()
    for file_name in os.listdir(html_files_path):
        # [zipcode, .html]
        zipcode = file_name.split('.')[0]
        print "    " + zipcode
        with nostdout(): #remove bs4 stdout
            parsed_html = read_and_parse_html(html_files_path + file_name)
            result_table = get_table_from_parsed_html(parsed_html)
            results = get_row_vals(result_table, zipcode)

        #append each row to a list generator
        all_licenses = chain(all_licenses, results)

        csv_name = '{}{}.csv'.format(CSV_output_path, zipcode)
        with open(csv_name, 'wb') as f:
            writer = csv.writer(f)
            writer.writerows(list(all_licenses))

    print "Extracted all data. Completed in: {} seconds.".format(round(time.time() - start_time, 3))

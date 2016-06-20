import bs4
import sys
from urllib import urlopen


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


def get_row_vals(result_table):
    ret = []

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
        ret.append(row_vals)

    return ret


if __name__ == "__main__":
    parsed_html = read_and_parse_html('../data_scraping/scraping_attempt_3/10001.html')
    result_table = get_table_from_parsed_html(parsed_html)
    print len(result_table)
    test = get_row_vals(result_table)
    print test[-5:]

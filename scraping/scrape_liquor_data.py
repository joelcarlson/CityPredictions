from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import requests
from bs4 import BeautifulSoup
import time

from NY_zips import NY_zips
from random import shuffle

import unicodecsv as csv


def get_table_by_zip(zipcode, output_path):

    driver = webdriver.Firefox()
    driver.get("https://www.tran.sla.ny.gov/JSP/query/PublicQueryPremisesSearchPage.jsp")
    elem = driver.find_element_by_name("zipCode")
    elem.send_keys(zipcode)
    elem.send_keys(Keys.RETURN)
    results_page = driver.page_source

    filename = "output_path/{}.html".format(ouput_path, zipcode)
    f = open(filename, 'w')
    f.write(u''.join(results_page).encode('utf-8').strip())
    f.close()

    driver.close()
    return None


if __name__ == "__main__":
    are_you_sure = raw_input("Scraping this data may bring down the NY SLA servers.\
    \nAre you sure you wish to do so? (Y/N)")
    if are_you_sure is 'Y':
        start_time = time.time()
        for zipcode in shuffle(NY_zips):

            get_table_by_zip(zipcode)
            print "Saved {} in {} seconds".format(zipcode,
                                        round(time.time() - start_time))
            start_time = time.time()

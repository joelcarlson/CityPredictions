from datetime import datetime
from collections import Counter
import random
import subprocess
import os
import fnmatch
import time
import pickle
import csv

def get_lat_lon(carrier, p_time, d_time, passengers, dist, p_lon, p_lat, rate, store, d_lon, d_lat, *args):
    return {'pickup':{'lat':float(p_lat), 'lon':float(p_lon)},
            'dropoff':{'lat':float(d_lat), 'lon':float(d_lon)}}

def get_zip_from_lat_lon(lat, lon):
    '''
    Ugly one liner -
    Calculate distance (euclidean - likely a bad choice)
    to each lat long in the zip/lat long dictionary
    extract the zip with the minimum distance to the given point
    '''
    return min([(((lat - val[0])**2 + (lon - val[1])**2)**0.5, zipcode) for zipcode, val in zip_coords_dict.items()])[1]

def create_taxi_dict(years):
    taxis = dict()
    for year in years:
        year_dict =  {  1:{'pickup':Counter(), 'dropoff':Counter()},
                        2:{'pickup':Counter(), 'dropoff':Counter()},
                        3:{'pickup':Counter(), 'dropoff':Counter()},
                        4:{'pickup':Counter(), 'dropoff':Counter()},
                        5:{'pickup':Counter(), 'dropoff':Counter()},
                        6:{'pickup':Counter(), 'dropoff':Counter()},
                        7:{'pickup':Counter(), 'dropoff':Counter()},
                        8:{'pickup':Counter(), 'dropoff':Counter()},
                        9:{'pickup':Counter(), 'dropoff':Counter()},
                       10:{'pickup':Counter(), 'dropoff':Counter()},
                       11:{'pickup':Counter(), 'dropoff':Counter()},
                       12:{'pickup':Counter(), 'dropoff':Counter()}}
        taxis[year] = year_dict
    return taxis

if __name__ == "__main__":

    input_path = "data/Taxis/raw/"
    output_path = "data/Taxis/intermediate/"

    start_time = time.time()

    # Get the lat long to zip correspondence dictionary
    with open('data/NY_Info/zip_coords_dict.pickle', 'rb') as handle:
        zip_coords_dict = pickle.load(handle)

    taxis = create_taxi_dict(range(2010,2017))

    #We will loop over each fill with the extension *.csv
    # We use the unix command 'wc -l filename' to get the length of the
    # csv so we know the upper range limit for our sample
    # We will sample 100000 rows from each csv!

    taxi_paths = fnmatch.filter(os.listdir(input_path), '*.csv')

    for taxi_data_year in taxi_paths:

        # get the size of data - this command is slow
        n_rows = subprocess.check_output(['wc', '-l', 'data/Features/feature_data.csv'])
        #n_rows = float(n_rows.split()[0])
        n_rows = 1000000000
        i = 0

        test_lst = list()

        #for line in open(input_path + taxi_data_year):
        f = open(input_path + taxi_data_year)
        while True:
            i += 1

            if i >=1000:
                break
            offset = random.randrange(n_rows)
            f.seek(offset)                  #go to random position
            f.readline()
            random_line = f.readline()

            row = random_line.split(',')



            try:
                date = datetime.strptime(row[1], '%Y-%m-%d %H:%M:%S')
                print date
                lat_lon = get_lat_lon(*row)

                pickup_zip = get_zip_from_lat_lon(lat_lon['pickup']['lat'], lat_lon['pickup']['lon'])
                dropoff_zip = get_zip_from_lat_lon(lat_lon['dropoff']['lat'], lat_lon['dropoff']['lon'])


                taxis[date.year][date.month]['pickup'][pickup_zip] += 1
                taxis[date.year][date.month]['dropoff'][dropoff_zip] += 1
            except:
                pass

        print "Processed {} rows in {} seconds".format(i, round(time.time() - start_time,3))
        with open(output_path + os.path.basename(taxi_data_year) + ".pickle", 'wb') as handle:
          pickle.dump(taxis, handle)



# Get the lat long to zip correspondence dictionary
with open('yellow_tripdata_2011.csv.pickle', 'rb') as handle:
    taxis = pickle.load(handle)

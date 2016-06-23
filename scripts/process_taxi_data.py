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

    input_path = "data/Taxis/intermediate/"
    output_path = "data/Taxis/pickle_files/"

    start_time = time.time()

    # Get the lat long to zip correspondence dictionary
    with open('data/NY_Info/zip_coords_dict.pickle', 'rb') as handle:
        zip_coords_dict = pickle.load(handle)

    taxis = create_taxi_dict(range(2010,2016))

    #Loop over CSV files, calc zip from lat long, add to dictionary
    taxi_paths = fnmatch.filter(os.listdir(input_path), '*.csv')

    for taxi_data_year in taxi_paths:

        i = 0
        for line in open(input_path + taxi_data_year):
            i += 1
            if i >= 100000:
                break
            row = line.split(',')

            try:
                date = datetime.strptime(row[1], '%Y-%m-%d %H:%M:%S')
                lat_lon = get_lat_lon(*row)

                pickup_zip = get_zip_from_lat_lon(lat_lon['pickup']['lat'], lat_lon['pickup']['lon'])
                dropoff_zip = get_zip_from_lat_lon(lat_lon['dropoff']['lat'], lat_lon['dropoff']['lon'])

                taxis[date.year][date.month]['pickup'][pickup_zip] += 1
                taxis[date.year][date.month]['dropoff'][dropoff_zip] += 1
            except:
                pass

        print "Processed {} rows in {} seconds".format(i, round(time.time() - start_time,3))
        # Save intermediate steps
        with open(output_path + os.path.splitext(taxi_data_year)[0] + ".pickle", 'wb') as handle:
          pickle.dump(taxis, handle)


    with open(output_path + "taxi_data.pickle", 'wb') as handle:
      pickle.dump(taxis, handle)

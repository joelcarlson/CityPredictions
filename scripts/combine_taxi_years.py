import pickle
import pandas as pd

if __name__ == "__main__":
    with open("data/Taxis/pickle_files/yellow_tripdata_2015_sample.pickle", 'rb') as handle:
        taxis = pickle.load(handle)

    dat = pd.DataFrame()
    for year in range(2010,2016):
        for month in range(1,13):
            year_month_dat = pd.DataFrame(taxis[year][month])
            year_month_dat['year'] = year
            year_month_dat['month'] = month
            frame = [dat, year_month_dat]
            dat = pd.concat(frame, axis=0)

    dat.reset_index(inplace=True)
    dat.rename(columns={'index':"zipcode"}, inplace=True)
    dat.to_csv("data/Taxis/taxi_data.csv", index=False)
    print "Saved Taxi Data."

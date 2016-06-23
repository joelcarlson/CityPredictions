echo Sampling 2010 taxi data
gshuf -n 1000000 data/Taxis/raw/yellow_tripdata_2010.csv > data/Taxis/intermediate/yellow_tripdata_2010_sample.csv
echo Sampling 2011 taxi data
gshuf -n 1000000 data/Taxis/raw/yellow_tripdata_2011.csv > data/Taxis/intermediate/yellow_tripdata_2011_sample.csv
echo Sampling 2012 taxi data
gshuf -n 1000000 data/Taxis/raw/yellow_tripdata_2012.csv > data/Taxis/intermediate/yellow_tripdata_2012_sample.csv
echo Sampling 2013 taxi data
gshuf -n 1000000 data/Taxis/raw/yellow_tripdata_2013.csv > data/Taxis/intermediate/yellow_tripdata_2013_sample.csv
echo Sampling 2014 taxi data
gshuf -n 1000000 data/Taxis/raw/nyc_taxi_data.csv > data/Taxis/intermediate/yellow_tripdata_2014_sample.csv
echo Sampling 2015 taxi data
gshuf -n 1000000 data/Taxis/raw/yellow_tripdata_2015.csv > data/Taxis/intermediate/yellow_tripdata_2015_sample.csv
echo Taxi sampling finished

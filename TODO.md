
# To Do

This is a running to do list and accomplishment log

# Monday June 20

#### Completed:

  - Reorganized repo
  - Built make file
  - Finished extracting data from SLA HTML source files
  - Mergeed latitude and longitude coordinates from zipcode R package
  - Mergeed .gov liquor data with SLA data (more precise lat longs)
  - Converted .mdb files to CSV files for consumption
    - Will likely not be used, lacking time series information

#### Difficulties

  - Spent too much time aimlessly cleaning data
    - Need better direction/goals
  - Wasted time getting data out of those hideous MSaccess files
    - Turned out to not be useful
  - Haven't yet defined prediction target or refined the valuation data, arguably the most important stuff

# Tuesday June 21


#### Completed:

  - Built first babysteps model
    - Using a prediction target I don't plan to use
    - Without most of the features

  - Merge zillow data with liquor data and amenity distance data
  - Aggregated liquor data by month
    - Counts of number issued and number expired
  - Extracted XML data from rec locations
    - Saved to a dataframe and complete
  - Explored the restaurant inspection data and it appears to be very rich
    - need to find DOMM website to understand what the scores mean, but looks simple
    - Merged with liquor data
  - Make final decision on what data to use
    - Going to use liquor, food ins, amenities, and ZHVI to predict the year over year change in rent by area.
    - Alternate: year over year change in listing vs selling price
      - Should check how many zip codes had a situation in which their median difference went up then down or vice versa
    - Aggregated all data by zip
      - It's not as granular as I would like, but it is the most common area metric, will be easiy to map, all my data has it, etc


# Wednesday June 22

#### Completed

  - Created a function which calculates approximate zipcode given lat and long coords
  - Downloaded and streamed through  > 100gb of taxi data from NY
    - Extracted 1M points from each year, aggregated
    - Merged taxi data with liquor and rental data
  - Decided on a reasonable prediction target...sorta





# Thursday June 23

#### To Do

  - Deal with sparsity in the data
    - apply a moving average to the liquor license data
  - Build a time series model to predict changes in rent using the liquor, taxi, and possibly ZHVI data
  - Find optimal lag time between parameters and change in rent year over year, or month over month
    - make sure data is properly cleaned
  - Consider clustering similar zipcodes??


# Friday June 24

#### To Do

  - Modeling!
  - Build function to score model predictions
  - Choose best model (optimize params)
    - Choose best features
  - Generalize model to make predictions on all the data!


# Tuesday June 27

#### To Do

  - Build visualizations
  - Validate model predictions
  - Build prediction pipeline


# To do overall

  - Mock up site design
  - Think about what analytics to put up when the user clicks an area
  - Get map bounding boxes for areas or zips or whatever you decide to use
  - Think about presentation story
    - "Before I begin this presentation I want you to think about why this house, which my parents just sold in Calgary Alberta was sold for less than 80% of list price, while this hom (shitty home in NY) sold for double what it was listed for. Of course, you are thinking "well obviously NY is a desirable palce to live", well, wasn't NY a desirable place to live 5 years ago? (graph showing trend in diff between listing and selling, or mention ho this sint necessarily consistent all over NY). What are the factors that are leading to this? More importantly, can we predict whch areas of a city are most likely to experience price increases over and above regular inflation?
    - "I wanted to answer this question, but wanted to do so using features that I thought were novel, which led me to two factors: "



```python

```

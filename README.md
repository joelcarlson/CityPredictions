# Predicting Changes in Rental Unit Prices in NYC

The goal of this project was to test two hypotheses:

  1. Changes in the rate of *Taxi pickups and dropoffs* in an area precedes changes in the price of rental units

  2. Changes in the rate of *liquor licenses issued* in an area precedes changes in the price of rental units

Why would anyone think these may predict changes in rental prices? 

Well, about three years ago I moved into a small neighborhood in South Korea. At the time it was a little dingy, mostly small local restaurants; I had been partially motivated to move there by the extremely low rent.

By the time I left two and a half years later the area was cleaner, had more upscale businesses, and heavy pedestrian traffic. The rental prices had also *skyrocketed*. Looking around the area I saw new coffee shops, new bars, and significant night life. That is, liquor serving establishments (which need licenses), and people (who need transportation - taxis). I wondered - Did these precede the rent increases? 

### Why Predict Rental Prices?

Aside from the obvious potential for investments in up-and-coming areas, another reason to investigate rental prices is to be able to predict which areas may undergo gentrification. Being able to anticipate gentrification could lend early insight to policy makers, who may then be able to implement measures such as rent-control to prevent local residents being priced out of their homes.

To build this project, clone the repo and run make from the base directory using:

```
git clone https://github.com/joelcarlson/CityPredictions.git

cd CityPredictions

make
```

## Methods

### The Data

Data for this project came primarily from three sources:

Taxi pickups and dropoffs were aggregated using the [New York City open taxi data portal](https://data.cityofnewyork.us/data?agency=Taxi+and+Limousine+Commission+%28TLC%29&cat=&type=new_view&browseSearch=&scope=). Files were downloaded as one ~30 Gb CSV per year, and aggregated using [shell scripts](LINK ME!).

Liquor licenses were downloaded from the [New York Liquor Authority database](http://SLA.org). Scraping was automated with [Selenium](LINK ME), and html data parsed with [BeautifulSoup](LINK ME).

[Rental prices from Zillow](http://www.zillow.com/research/data/#median-home-value) were used as prediction targets.

<img src="https://raw.githubusercontent.com/joelcarlson/CityPredictions/master/figures/MRP_by_Borough_single_wide.png" height="50%" width="100%" />

Scripts for downloading, cleaning, and combining the data can be found [here]()[here]()[here]().

For a complete listing of the data sources considered and compiled for this project, see [data.md](https://github.com/joelcarlson/CityPredictions/blob/master/data.md)

### Data Pipeline

The prediction target for this project is not the median monthly rental price in a given zipcode, rather it is the *change* in monthly rental price. Therefore the monthly changes must be extracted from each zipcode, shown below:

<img src="https://raw.githubusercontent.com/joelcarlson/CityPredictions/master/figures/MRP_raw_and_MoM.png" height="50%" width="50%" />

This is, in a word, noise. To coerce the data into a better behaved form I used STL decomposition to remove the seasonal component, and create a useful trendline. 

The decomposition and resulting better behaved prediction target:


<img src="https://raw.githubusercontent.com/joelcarlson/CityPredictions/master/figures/MRP_2_STL_superimposed.png" height="50%" width="100%" />





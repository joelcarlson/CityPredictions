import pandas as pd
import time

if __name__ == "__main__":
    start_time = time.time()

    print "Processing FoodService data."
    raw_ins_path = "data/FoodService/raw/"
    output_path = "data/FoodService/"

    ins_results = pd.read_csv(raw_ins_path + "DOHMH_New_York_City_Restaurant_Inspection_Results.csv")

    print "    Data loaded"
    # Convert to datetime
    ins_results['INSPECTION DATE'] = pd.to_datetime(ins_results['INSPECTION DATE'])

    # Reindex and extract required info
    ins_results.index = ins_results['INSPECTION DATE']
    ins_results['Year'] = ins_results.index.year
    ins_results['Quarter'] = ins_results.index.quarter
    print "    Dates converted"

    # Collect counts of critical flags and grades by zipcode/year/quarter
    ins_agg_critical = pd.DataFrame(ins_results.groupby(['ZIPCODE', 'Year', 'Quarter', 'CRITICAL FLAG'])['CRITICAL FLAG'].agg('count'))
    ins_agg_grade = pd.DataFrame(ins_results.groupby(['ZIPCODE', 'Year', 'Quarter', 'GRADE'])['GRADE'].agg('count'))

    print "    Grouping completed"
    # Save
    ins_agg_critical.to_csv(output_path + "food_ins_criticalFlags.csv")
    ins_agg_grade.to_csv(output_path + "food_ins_grades.csv")
    print "Completed processing FoodService data in {} seconds.".format(round(time.time() - start_time,3))

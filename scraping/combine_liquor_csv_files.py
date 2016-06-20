import os
import time
if __name__ == "__main__":
    start_time = time.time()

    CSV_file_path = 'data/Liquor/CSVs/'
    single_CSV_output_path = 'data/Liquor/'
    print "Compiling Liquor CSV files"
    fout = open(single_CSV_output_path + 'All_Licenses.csv', "a")
    fout.write('premises_name,address,license_class,license_type,expiration_date,license_status,link,zipcode\n')

    for csv_file in os.listdir(CSV_file_path):
        f = open(CSV_file_path + csv_file)
        for line in f:
             fout.write(line)
        f.close() # not really needed
    fout.close()
    print "Successfully compiled Liquor CSV files. Completed in {} seconds.".format(round(time.time() - start_time, 3))

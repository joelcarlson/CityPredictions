import pandas as pd
import xml.etree.ElementTree as ET
import re
import os
import time
import numpy as np


def get_info_from_xml_file(xml_file_path, facility_type, output_path):
    tree = ET.parse(xml_file_path)
    root = tree.getroot()
    facility_lst = list()
    for facility in list(root):
        fac_dict = {'Facility':np.nan, 'Name':np.nan, 'Lat':np.nan, 'Long':np.nan, 'Location':np.nan, 'Zip':np.nan}
        fac_dict['Facility'] = facility_type
        for attribute in list(facility):
            # extract everything after the 'txt}' and until the newline
            tag = re.search('(?<=txt\})[^\n]+', attribute.tag).group(0)

            # All we care about is name, lat, long
            if tag == "Name":
                fac_dict["Name"] = attribute.text
            if tag == "lat":
                fac_dict['Lat'] = attribute.text
            if tag == "lon":
                fac_dict['Long'] = attribute.text
            if tag == 'Location':
                fac_dict['Location'] = attribute.text
            if tag == "ZIP":
                fac_dict['Zip'] = attribute.text

        facility_lst.append(fac_dict)

    facility_lst = pd.DataFrame(facility_lst)
    facility_lst.to_csv(output_path + facility_type + ".csv", index=False, encoding='utf-8')


if __name__ == "__main__":
    start_time = time.time()
    print "Extracting XML data:"
    # We define nice names for each xml file (non scalable solution!)
    file_name_map = {"Basketball_Courts.xml":"Basketball",
                     "DPR_Playgrounds_001.xml":"Playgrounds",
                     "DPR_Barbecue_001.xml":"BBQ",
                     "DPR_Handball_001.xml":"Handball",
                     "DPR_RecreationCenter_001.xml":"RecCenter",
                     'DPR_PublicComputerResourceCenter_001.xml':"ComputerRoom",
                     "DPR_Hiking_001.xml":"Hiking",
                     "DPR_RunningTracks_001.xml":"RunningTrack",
                     "DPR_HistoricHouses_001.xml":"HistoricHouses",
                     "DPR_Tennis_001.xml":"Tennis",
                     "DPR_Horseback_001.xml":"HorseTrail",
                     "DPR_Zoos_001.xml":"Zoo",
                     "DPR_IceSkating_001.xml":"IceRink",
                     "DPR_marinas_001.xml":"Marina",
                     "DPR_NatureCenters_001.xml":"Nature"}


    XML_path = 'data/Recreation_Locations/XML/'
    output_path = 'data/Recreation_Locations/intermediate/'
    for file_path in os.listdir(XML_path):
        facility_type = file_name_map[file_path]
        print "    " + facility_type
        get_info_from_xml_file(XML_path + file_path, facility_type, output_path)
    print "Completed XML extraction in {} seconds.".format(round(time.time() - start_time, 3))

    # Save into final DF
    rec_df = pd.DataFrame()
    for file_path in os.listdir(output_path):
        next_df = pd.read_csv(output_path + file_path)
        frame = [rec_df, next_df]
        rec_df = pd.concat(frame, axis=0)

    rec_df.to_csv('data/Recreation_Locations/recreation_locations.csv', index=False)

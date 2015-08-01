#!/usr/bin/env python

import csv

f = open('new tif - Copy of TIF_Report_2013_v1.2-Omaha.csv', 'r')
of = open('tif2013.csv', 'w')

reader = csv.reader(f)
writer = csv.writer(of, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)

rownum = 0
for row in reader:
    # Save header row.
    if rownum < 5:
        writer.writerow(row)
    else:
        # data in 12
        # name in 12
        # addr in 13
        # description in 14

        text = row[12].split('\n')

        if len(text) == 3:
	        row[12] = text[0]
	        row[13] = text[1]
	        row[14] = text[2]

	        if row[12].startswith('Name of Project: '):
	        	row[12] = row[12][17:]
	        if row[13].startswith(' '):
	        	row[13] = row[13][1:]
	        if row[14].startswith(' Description: '):
	        	row[14] = row[14][14:]

	        if row[13].endswith('City of Omaha.'):
	        	row[13] = row[13].replace('City of Omaha.', 'Omaha, NE')

        writer.writerow(row)
            
    rownum += 1

of.close()
f.close()

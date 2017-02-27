# Omaha City Council Meeting Minutes

Downloading, converting, and scanning PDF files from cityofomaha.org for TIF information.

[Click here to view final output](https://github.com/opennebraska/pri-tif/tree/master/cityofomaha.org/tif_pretty)

Software:
* scraper.pl - Pulls PDF files from cityofomaha.org into our own repository.
* makepretty.pl - Scans text versions of the PDF files, finding occurrences of TIF.

Archive (as of Feb 27 2017):
* Nov 4 2008 through February 14 2017.
* 362 .pdf files totaling 96MB in our repository.
* None of the data files sit in github.com. The PDF and text files [are sitting in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0).

The `scraper.pl` program can no longer retrieve a full archive because cityofomaha.org
requires a Javascript client for some reason. 
the PDFs, convert them to text, and spit out the "pretty TIF only" 
markdown formatted file like so: 

````
mkdir dump
scraper.pl
cd dump
ls *pdf | xargs -L 1 pdftotext -nopgbrk
cd ..
makepretty.pl
````

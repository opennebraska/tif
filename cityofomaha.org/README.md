# Omaha City Council Meeting Minutes

Downloading, converting, and scanning PDF files from cityofomaha.org for TIF information.

[Click here to view final output](https://gist.github.com/jhannah/6b7bdab2c32822af7d99).

Software:
* scraper.pl - Pulls PDF files from cityofomaha.org into our own repository.
* makepretty.pl - Scans text versions of the PDF files, finding occurrences of TIF.

Archive:
* Our PDF archive currently spans Nov 4 2008 through March 22 2016.
* As of Mar 25 2016, 326 .pdf files totaling 80MB in our repository.
* None of the data files sit in github.com. The PDF and text files [are sitting in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0).

But if you prefer to start from scratch, you can download all 
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

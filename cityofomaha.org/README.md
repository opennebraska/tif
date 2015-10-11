None of the data sits in this repository. As of Aug 1 2015, 204 .pdf files 
totaling 55MB were available. You can download all the PDFs and convert
them to text like so:

````
mkdir dump
scraper.pl
cd dump
ls *pdf | xargs -L 1 pdftotext -nopgbrk
````

[Results](https://gist.github.com/jhannah/6b7bdab2c32822af7d99)


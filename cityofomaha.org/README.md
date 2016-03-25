None of the data sits in this repository. 
As of Mar 25 2016, 326 .pdf files totaling 80MB were available. 
You can download all the PDFs and convert them to text like so:

````
mkdir dump
scraper.pl
cd dump
ls *pdf | xargs -L 1 pdftotext -nopgbrk
cd ..
makepretty.pl
````

[Results](https://gist.github.com/jhannah/6b7bdab2c32822af7d99)


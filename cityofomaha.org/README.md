None of the data sits in this repository. 
As of Mar 25 2016, 326 .pdf files totaling 80MB were available. 
Those PDF and text files [are sitting in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0).
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

[Results](https://gist.github.com/jhannah/6b7bdab2c32822af7d99)


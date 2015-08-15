# Policy Research & Innovation - TIF

* [Open Nebraska](http://opennebraska.io) [Meetups](http://www.meetup.com/Open-Nebraska-Meetup/)
* [Policy Research & Innovation](http://www.prineb.org)

Tax Increment Financing (TIF) is one of those dry, abstract governmental
issues that has powerful effects on how we live. TIF was originally conceived
to promote economic development in marginalized areas, recently, it has been
used primarily to build higher income apartments and condos. Thus, the issues
with using TIF policy include gentrification, relocating (rather than
reducing) poverty, using public funds for private gain and governmental
accountability and transparency, among others. That's why it's important to
have information easily available for citizens to review and reach informed
opinions.

Long run, aim would be to provide information on connections. Maybe to put
together a power structure database or force graph.  Which city council
members voted on these projects;

* Who has donated to their campaigns; 
* Other connections those city council members have to construction firms, developers, etc..

## HOWTO

None of the data sits in this repository. As of Aug 1 2015, 204 .pdf files 
totaling 55MB were available. You can download all the PDFs and convert
them to text like so:

````
mkdir dump
./tif_scraper.pl
cd dump
ls *pdf | xargs -L 1 pdftotext -nopgbrk
````

[Results](https://gist.github.com/jhannah/6b7bdab2c32822af7d99)

## Links

* [Omaha City Council Agendas](http://www.cityofomaha.org/cityclerk/city-council/agendas)
* [Omaha City Council - Better Agendas](http://agendas.dataomaha.com/) [source code](https://github.com/mattdsteele/hackomaha-council-agendas)



# Omaha City Council Meeting Minutes

Downloading, converting, and scanning PDF files from cityofomaha.org for TIF information.

[Click here to view final output](https://github.com/opennebraska/tif/tree/main/cityofomaha.org/tif_pretty)

Software:

- scraper.pl + download-omaha-pdf.js - Pulls PDF files from cityofomaha.org into our own repository.
- makepretty.pl - Scans text versions of the PDF files, finding occurrences of TIF.

Archive (as of Feb 27 2017):

- Nov 4 2008 through Feb 14 2017.
- All of 2024 through Apr 29 2025.
- 414 .pdf files totaling 139MB.
- None of the data files sit in github.com. The PDF and text files
  [are sitting in Dropbox](https://www.dropbox.com/sh/lb1kwtfou7b2kg4/AACAZrrrBOnzRUmgK6ek14a1a?dl=0).

`scraper.pl` now runs `download-omaha-pdf.js` because they keep getting more aggressive
about blocking automated retrieval of public records.

Download the PDFs, convert them to text, and spit out the "pretty TIF only"
markdown formatted file like so:

```
brew install poppler      (installs pdftotext)

mkdir dump
scraper.pl
cd dump
ls *pdf | xargs -L 1 pdftotext -nopgbrk
cd ..
makepretty.pl
```

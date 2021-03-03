# Static website

[Click here to view the public website on the Internet](http://nebraska.tif.report).

We use GitHub Pages for our hosting. 

First, download or build a local copy of the database. See the instructions in the `/db` directory.

Then, from the root directory of this repository:

    $ perl static-www/scripts/generate_www.pl

You have now generated the entire site into your `static-www/www` directory. Look it over, 
make sure your changes worked as you expected.

If everything is good, commit everything to the `gh-pages` branch of this repository. Push that
to GitHub, and your changes are now on the public website.

### Laziness tip

For my own convenience, I clone the repository twice. Once for `main` and once for `gh-pages`. 
I then sym-link `static-www/www` to the 2nd clone. 

    $ ls -al tif/static-www/www
    lrwxr-xr-x  1 jhannah  staff  22 Apr 18 10:30 tif/static-www/www -> ../../tif-gh-pages
    

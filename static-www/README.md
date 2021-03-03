# Static website

[Click here to view the public website on the Internet](http://nebraska.tif.report).

First, download or build a local copy of the database. See the instructions in the `/db` directory.

Then, from the root directory of this repository:

    $ perl static-www/scripts/generate_www.pl

You have now generated the entire site into your `static-www/www` directory. Look it over, 
make sure your changes worked as you expected.

If everything is good, commit everything to the `static-www` branch of this repository. Push that
to GitHub. Now ssh into nebraksa.tif.report and `git pull`.

### Laziness tip

For my own convenience, I clone the repository twice. Once for `main` and once for `static-www`.
I then sym-link `static-www/www` to the 2nd clone. 

    $ ls -al tif/static-www/www
    lrwxr-xr-x  1 jhannah  staff  22 Apr 18 10:30 tif/static-www/www -> ../../tif-static-www
    

Description
===========

A small ruby program used for parsing copy documents, and putting the content into a CSV file to be uploaded. Used for a DAC Proprietary platform. http://www.dacgroup.com/page-torrent.htm

Installation
------------

Requires ruby 1.9.3 or greater to run.
For Mac OSX and Linux, I recommend rvm: http://rvm.beginrescueend.com/

Once installed, clone the project locally:

```bash
git clone http://github.com/agmcleod/Copy-Process.git
```

Then run

    bundle install
    rake db:create
    rake db:migrate
    rails s
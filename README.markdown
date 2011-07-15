Description
===========

A small ruby program used for parsing copy documents, and putting the content into a CSV file to be uploaded. Used for a DAC Proprietary platform. http://www.dacgroup.com/page-torrent.htm

Installation
------------

Requires ruby 1.9.1 or greater to run (I now use 1.9.2). 
For Mac OSX and Linux, I recommend rvm: http://rvm.beginrescueend.com/

Once installed, either download the source, or use git to grab it:

```bash
git clone http://github.com/agmcleod/Copy-Process.git
```

Usage
-----

Open up command prompt/terminal, browse to the directory and run using:

```bash
parse_copy
```

You may need to update the parse_copy file's shebang to point to your installation of ruby.

Then enter in paths to the text files, separated by semicolons. Example:
dumpsters.txt;recycling.txt;garbage-pickup.txt. Or you can tell it to read all text files in the current directory by typing: *.txt
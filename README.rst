~~~~~~~~~~
Bashpodder
~~~~~~~~~~

This is my modified version of the bashpodder podcatcher script. It is available under the GPL.

The original is available at https://github.com/lincgeek/bashpodder .
This includes enhancements made by Ellen Taylor available at https://github.com/ellencubed/bashpodder .

Filenames from popupchinese.com podcasts are automatically cleaned up before downloading.

Usage
~~~~~

This iteration assumes that bashpodder.bash, bp.conf, parse_enclosure.xsl, and podcast.log are in the directory you wish to download podcasts to.

To print out (and store in test.log) what files bashpodder would download without actually downloading them::
  
  bash$ bash bashpodder.bash test

To download any podcast files not found in podcast.log::
  
  bash$ bash bashpodder.bash download

Like the original bashpodder and unlike Ellen Taylor's version which downloads only the last podcast 
the download action will download ALL available podcasts not recorded in pdocast.log.
However the test action shows you all the files it will download so you can place undesired ones the into podcast.log 
before actually downloading.  To mark ALL podcasts as downloaded (so in the future you'll only download new podcasts) 
you can do::

    bash$ bashpodder.bash test >> podcast.log

You can sometimes place previously downloaded files from other podcatchers into podcast.log using the ``ls`` command::

    bash$ ls PopupChinese/*.mp3 >> podcast.log

Files downloaded by bashpodder will automatically be recorded into podcast.log.  
To re-download simply delete the entry and run bashpodder.

Bashpodder requires you have bash, wget, awk, sed and xsltproc.

Config
~~~~~~

Feeds are defined in bp.conf as::

  http://podcastfeedurl.com/rss feeddir

'feeddir' being the subdirectory for that particular feed. 

bp.conf.example contains an example with some of my favorite non-personalized Podcasts (to use it rename it to bp.conf).

The podcast directory to download files is defined by the datadir environmental variable in bashpodder.bash and defaults to the working directory.

Create playlists
----------------
You can create simple playlists by listing files in a text files with m3u suffix::

    bash$ ls PopupChinese/*dialogue.mp3 > PopupChinese/dialogue_playlist.m3u

A ``m3u`` playlist is automatically created in each Podcast directory.

Schedule jobs
-------------

To regularly download scripts you can set up a crontab job.

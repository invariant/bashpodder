#!/bin/bash
# By Linc 10/1/2004
# Find the latest script at http://lincgeek.org/bashpodder
# Revision 1.21 12/04/2008 - Many Contributers!
# If you use this and have made improvements or have comments
# drop me an email at linc dot fessenden at gmail dot com
# and post your changes to the forum at http://lincgeek.org/lincware
# I'd appreciate it!

# modified by ellen taylor (ellencubed at gmail dot com)
# modified by trevor davis (trevor.l.davis at gmail dot com) 2013

# Cd to script dir
cd $(dirname $0)

# datadir is the directory you want podcasts saved to:
# datadir=$HOME/Documents/Podcasts
datadir="$(pwd)/podcasts"    

function main {
    case $1 in
        "download")
            rm new.log
            download new.log true
            # Move dynamically created log file to permanent log file:
            cat new.log > temp.log
            cat podcast.log >> temp.log
            sort temp.log | uniq > podcast.log
            rm temp.log
            ;;
        "test")
            download test.log false
            cat test.log
            ;;
        "help" | "usage" | *)
            usage;;
    esac
}

function usage {
    echo "Usage: bashpodder.bash download | test | help"
}

function produce_filename {
    url=$1
    filename=$(echo "$url" | awk -F'/' {'print $NF'} | awk -F'=' {'print $NF'} | awk -F'?' {'print $1'})
    echo $filename
}

function download {
    logfile=$1
    download_media=$2

    # create datadir if necessary:
    if $download_media ; then
        mkdir -p $datadir
    fi
    touch podcast.log

    # Delete any temp file:
    rm -f $logfile
    touch $logfile
    
    # Read the bp.conf file and wget any file not already in the podcast.log file (if ``download_media`` is true):
    while read podcastfields
        do
        podcast=$(echo $podcastfields | cut -d' ' -f1)
        dname=$(echo $podcastfields | cut -d' ' -f2)
        #file=$(xsltproc parse_enclosure.xsl $podcast 2> /dev/null || curl -v $podcast | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
        echo "checking $dname..."    
        file=$(curl -s $podcast | xsltproc parse_enclosure.xsl - 2> /dev/null)    
        mkdir -p $datadir/$dname
        for url in $file
            do
            filename=$(produce_filename $url)           
            if ! grep "$dname/$filename" podcast.log > /dev/null ; then                
                echo " new: $filename"                
                if $download_media ; then
                    echo " downloading: $url"
                    curl -L --retry 3 -A BashPodder -C - -o "$datadir/$dname/$filename" "$url"
                fi                
                echo "$dname/$filename" >> $logfile
                echo "$dname/$filename" >> "tocopy.log"
            fi
            done
        done < bp.conf

    ./transfer.bash
}

main $@

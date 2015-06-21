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

# datadir is the directory you want podcasts saved to:
# datadir=$HOME/Documents/Podcasts
datadir=$(pwd)

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

function clean_popup {
    url=$1
    filetype=$(echo $url | sed -e 's/.*\(mp3\|pdf\)$/\1/' )
    lesson=$(echo $(basename $url) | sed -e 's/\(.*\).\(pdf\|mp3\)%.*/\1/' )
    # lesson=$(echo $url | cut -d/ -f7)
    level=$(echo $url | cut -d/ -f6)
    mediatype=$(echo $url | cut -d/ -f5)
    # if [ $mediatype = $filetype ] ; then
    #     echo "popupchinese-${level}-${lesson}.$filetype"
    # else
    # fi
    echo "popupchinese-${level}-${lesson}-${mediatype}.$filetype"
}

function produce_filename {
    url=$1
    if [[ $url =~ "popupchinese.com" ]] ; then
        filename=$(clean_popup $url)
    else
        #filename=$(echo $url | awk -F'/' '{print $NF}')
        filename=$(echo "$url" | awk -F'/' {'print $NF'} | awk -F'=' {'print $NF'} | awk -F'?' {'print $1'})
    fi
    echo $filename
}

function download {
    logfile=$1
    download_media=$2

    # Make script crontab friendly:
    cd $(dirname $0)

    # create datadir if necessary:
    if $download_media ; then
        mkdir -p $datadir
    fi
    touch podcast.log

    # Delete any temp file:
    rm -f $logfile
    touch $logfile

    # Create new playlist
    # echo "#Last fetch on $(date +%Y-%m-%d) @ $(date +%r)" > $datadir/latest.m3u

    # Read the bp.conf file and wget any file not already in the podcast.log file (if ``download_media`` is true):
    while read podcastfields
        do
        podcast=$(echo $podcastfields | cut -d' ' -f1)
        dname=$(echo $podcastfields | cut -d' ' -f2)
        file=$(xsltproc parse_enclosure.xsl $podcast 2> /dev/null || wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | sed -n 's/.*url="\([^"]*\)".*/\1/p')
        mkdir -p $datadir/$dname
        for url in $file
            do
            filename=$(produce_filename $url)
            if ! grep "$filename" podcast.log > /dev/null ; then
                echo $filename >> $logfile
                if $download_media ; then
                    wget -t 10 -U BashPodder -c -q -O $datadir/$dname/$filename "$url"
                fi
                #echo $datadir/$dname/$filename >> $datadir/latest.m3u
            fi
            done
        done < bp.conf
    popup_script=popup_tools/run_all_utilities.sh
    if [ -f $popup_script ]
    then
        bash $popup_script
    fi

}

main $@

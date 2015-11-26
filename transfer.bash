#!/bin/bash

destdisk="/Volumes/U32"
otherdisk="/Volumes/CLIP"

destdir="${destdisk}/podcasts"
if ! [ -d "$destdir" ]; then
	echo "Can't find destination directory ($destdir)"
	exit 1
fi

srcdir="/Users/nick/source/bashpodder/podcasts"
if ! [ -d "$srcdir" ]; then
	echo "Can't find source directory ($srcdir)"
	exit 1
fi

newlist="/Users/nick/source/bashpodder/tocopy.log"
if ! [ -f "$newlist" ]; then
	echo "No list ($newlist)"
	exit 1
fi

rsync -a -v --progress --files-from "$newlist" "$srcdir/" "$destdir/"
mv -vf "$newlist" "$destdir/new.m3u"

diskutil eject $destdisk
diskutil eject $otherdisk
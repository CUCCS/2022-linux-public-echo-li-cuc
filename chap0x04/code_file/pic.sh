#!/usr/bin/env bash

#先写一个help，搭框架。有问题再修改.
function help { 
    echo "-h        Show this help"
    echo "-g        Compress all Jpeg pictures with gzip"
    echo "-b        Compress all Jpeg pictures with bzip2"
    echo "-t        Create an archive and compress"
    echo "-s        Compress the rasolution while keep the aspect ratio"
    echo "-w        Watermark the picture"
}

function gzipJpeg {
    find "$1" -name "*.jpg" | xargs gzip 
}

function bzip2Jpeg {
    find "$1" -name "*.jpg" | xargs bzip2 
}

function bunzip2Jpeg {
    find "$1" -name "*.bz2" | xargs bunzip2
}


function tarJpeg {
    find "$1" -name "*.jpg" | xargs tar -czf "$1/JpegTar.tar.gz"
}

function scalePicture {
    cd "$1" || (echo "didn't find $1"&&exit) 
    mogrify -resize "$2" "*.jpg"||echo "no jpg picture in folder"
    mogrify -resize "$2" "*.png"||mogrify -resize "$2" "*.PNG"||echo "no png picture in folder"
    mogrify -resize "$2" "*.svg"||echo "no svg picture in folder"
}

function watermark {
    cd "$1" || (echo "didn't find $1"&&exit) 
    mogrify -pointsize 16 -fill white -weight bolder -gravity southeast -annotate +5+5 "$2" * 
}

place=${*: -1}

while getopts 'hgbdts:w:' opration; do
    case $opration in
    h) 
        help
        exit 0 ;;

    g)
        gzipJpeg "${place}";;

    b)
        bzip2Jpeg "${place}" ;;

    d)
        bunzip2Jpeg "${place}" ;;

    t)
        tarJpeg "${place}" ;;
    
    s)
        scalePicture "${place}" "$OPTARG" ;;

    w)
        watermark "${place}" "$OPTARG" ;;
    \?)
       echo "illegal argument"
       exit 1 ;;
    esac
done
exit 0
#!/usr/bin/env bash

#先写一个help，搭框架。有问题再修改.
function help { 
    echo "usage:bash pic.sh {-h|-b|...}[-h|-b|...].. target_folder"
    echo "-h          Show this help"
    echo "-b          Compress all Jpeg pictures with bzip2"
    echo "-t          Create an archive and compress"
    echo "-s N%       Compress the rasolution while keep the aspect ratio"
    echo "-w text     Watermark the picture"
    echo "-p text     add prefix"
    echo "-r text     add suffix"
    echo "-c          change syg/png to jpg"
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
    cd "$1" || (echo "didn't find $1"&&exit 1) 
    mogrify -pointsize 16 -fill white -weight bolder -font Arial -gravity southeast -annotate +5+5 "$2" ./* 
}

function prefix {
    cd "$1" || (echo "didn't find $1"&& exit 1)
    for file in *; do
    mv -f "$file" "$2_$file"
    done
}

function suffix {
    cd "$1" || (echo "didn't find $1" && exit 1)
    for file in *; do
        origin_name=${file%.*}
        extension=${file##*.}
        mv -f "$file" "${origin_name}_$2.${extension}"
    done
}

function changeFormat {
    cd "$1" || (echo "didn't find $1" && exit 1)
    for file in -exec $(find "*.png" -o "*.svg"); do
        origin_name=${file%.*}
        convert "$file" "${origin_name}.jpg"
    done
}

place=${*: -1}

while getopts 'hbdts:w:p:r:c' opration; do
    case $opration in
    h) 
        help
        exit 0 ;;

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
    
    p)
       prefix "${place}" "$OPTARG" ;;
    
    r)
       suffix "${place}" "$OPTARG" ;;
    
    c)
       changeFormat "${place}" ;;

    \?)
       echo "illegal argument"
       exit 1 ;;
    esac
done
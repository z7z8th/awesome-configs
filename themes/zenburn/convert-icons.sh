#!/bin/sh

find icons -name "*.png" | while read f; do
    convert $f -resize 32x32 icons-32x32/`basename $f`
done

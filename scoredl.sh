#!/bin/bash

i=0
res=0

`wget -q -O page $1`
addr=`grep -m1 -oP "https://..*score_0.png" page | rev | cut -c6- | rev`
nom=`grep -o "<title>.*sheet.*</title>" page | cut -c8- | rev | cut -c60- | rev`

while [ $res = 0 ]
do
	r=`wget -q "${addr}${i}.png"`
	res=$?
	i=$((i+1))
done

scores=`ls | grep "score_[0-9]*.png"`

`convert -quiet $scores "${nom}.pdf"` && echo "Finished downloading."

`rm -f page score_[0-9]*.png`

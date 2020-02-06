#!/bin/bash

function validate_url() {
  curl --output /dev/null --silent --head --fail "$1"
}

#TODO vérifier l'install

page=`wget -qO- $1`

if [ $? != 0 ]
then
  echo "ERROR : Invalid URL $1"
  exit 1
fi

#Répertoire de toutes les pages de la partition
scores_dir_url=`awk 'match($0, /^<meta property="og:image" content="(.*)score.*@.*">$/, m) {print m[1];}' <<< $page`

if [ $? != 0 ]
then
  echo "ERROR : Unable to fetch scores directory."
  exit 2
fi

title=`awk 'match($0, /^<meta property="og:title" content="(.*)">$/, m) {print m[1];}' <<< $page`

if [ $? != 0 ]
then
  echo "ERROR : Unable to fetch score's title."
  exit 3
fi

#Type des fichiers, svg si disponible, sinon png
score_file_type='png'

if validate_url "${scores_dir_url}score_0.svg"
then
  score_file_type='svg'
fi

i=0
scores=''

while [ 1 ]
do
  score_i_file="score_${i}.${score_file_type}"
  score_i_url="${scores_dir_url}${score_i_file}"

  if validate_url "$score_i_url"
  then
    echo "Downloading ${score_i_file} ..."
    #TODO passer par des variables
    `wget -q -O "${score_i_file}" "$score_i_url"`
    echo "Done."
    echo "Converting ${score_i_file} to score_${i}.pdf ..."
    `inkscape --export-pdf="score_${i}.pdf" "${score_i_file}"`
    echo "Done."
    echo "Removing ${score_i_file} ..."
    `rm -f "${score_i_file}"`
    echo "Done."
    scores="${scores} score_${i}.pdf"
    i=$((i + 1))
  else
    break
  fi
done

echo "Combining PDFs."
`pdfunite $scores "${title}.pdf"`
echo "Removing tmp files."
`rm -f $scores`

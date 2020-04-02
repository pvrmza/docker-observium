#!/bin/bash

# el nombre de la imagen va a ser el nombre del directorio actual si no se especifica
if test -z $1; then
	IMAGE=`basename $(pwd)`
else
	IMAGE=$1
fi

# que el TAG sea la fecha de creacion de la imagen si no se especifica
if test -z $2; then
	TAG=`date +%y%m%d`
else
	TAG=$2
fi


wget -c http://www.observium.org/observium-community-latest.tar.gz -O files/observium-community-latest.tar.gz

echo "Building $IMAGE con tag $TAG"

docker build --rm -t $IMAGE:$TAG .

docker image ls | egrep $IMAGE


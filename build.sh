#!/bin/sh

cp --recursive ../.certifications ./.certifications
cp ../keys.txt .

sudo docker build -t litterbugclient .

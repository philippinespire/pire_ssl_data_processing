#!/bin/bash

git pull
git add ./*
git commit -m "$1"
git push -u

chmod -R 777 *

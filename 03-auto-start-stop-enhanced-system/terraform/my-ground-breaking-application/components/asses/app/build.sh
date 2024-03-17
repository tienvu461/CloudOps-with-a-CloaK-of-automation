#!/bin/bash

set -ex

APP_NAME=asses
VERSION=$(date +%Y%m%dT%H%M%S)
LATEST_ZIP=$APP_NAME-latest.zip
VERSIONING_ZIP=$APP_NAME-$VERSION.zip
BUCKET_NAME=${S3_BUCKET:=powertech-bastion-asses-source}

# zip -r $VERSIONING_ZIP ./app/*.py
(cd app && zip -r $VERSIONING_ZIP *.py)

aws s3 cp ./app/$VERSIONING_ZIP s3://$S3_BUCKET/$VERSIONING_ZIP
aws s3 cp ./app/$VERSIONING_ZIP s3://$S3_BUCKET/$LATEST_ZIP

rm -rf ./app/$VERSIONING_ZIP

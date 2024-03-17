#!/bin/bash
set -e

FUNCTION_NAME_NAME=$(basename "$PWD")
# DOCKER_IMAGE="public.ecr.aws/lambda/python:3.8"
DOCKER_IMAGE="python:3.9"

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "The script to build lambda function in python."
   echo
   echo "Syntax: build.sh [-r|h]"
   echo "options:"
   echo "h     Print this Help."
   echo "r     Which tool we is used to install requirements for the lambda function."
   echo "      Is it docker or docker-compose?. Default is docker"
   echo
}


############################################################
############################################################
# Main program                                             #
############################################################
############################################################
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
DOCKER_TOOL=docker
while getopts ":hr:" option; do
	case $option in
		  h) # display Help
		     Help
		     exit;;
		  r) # Using docker-compose to build
		     DOCKER_TOOL=$OPTARG;;
		  \?) # Invalid option
		     echo "Error: Invalid option"
		     exit;;
	esac
done

rm -rf ./build
mkdir build
cd build
rsync -av --exclude='test.py' --exclude='sns.json' ../src/* ./

if [ "$DOCKER_TOOL" = "docker-compose" ]; then
	echo "To package the Lambda code by docker-compose + Docker"
	docker-compose build base && docker-compose up base
else
	echo "To package the Lambda code by Docker"
	docker run -i --rm \
		--entrypoint '/bin/bash' \
		-v ${PWD}:/src ${DOCKER_IMAGE} \
		-c 'cd /src && pip3 install -t . -r ./requirements.txt && find . -type d -name "__pycache__" -exec rm -rf {} +'

fi

rm -f ./../${FUNCTION_NAME_NAME}.zip
zip -r ./../${FUNCTION_NAME_NAME}.zip ./*
cd ..
if [  -n "$(uname -a | grep Ubuntu)" ]; then
    sudo rm -rf ./build
else
    rm -rf ./build
fi
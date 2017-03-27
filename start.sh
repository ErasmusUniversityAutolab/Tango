#!/bin/bash

IMAGES_DIR="AutogradingDocker"

build_images() {
	cd ${IMAGES_DIR}
	echo "(Re)Building docker images ..."
	./build_all.sh
	cd ..
}

clone_images() {
	echo "Cloning autograding Dockerfiles from GitHub ..."
	git clone https://github.com/ErasmusUniversityAutolab/AutogradingDocker ${IMAGES_DIR}
}

build_if_needed() {
	cd ${IMAGES_DIR}
	# check if pull is needed (i.e. docker images have changed)	
	git fetch origin
	reslog=$(git log HEAD..origin/master --oneline)
	if [ "${reslog}" != "" ]
	then
		git merge origin/master
		./build_all.sh
	fi
	cd ..
}

service docker start
service supervisor start &
sleep 5

cd /opt/TangoService/Tango

if [ ! -d "${IMAGES_DIR}" ]
then
	clone_images
	build_images
fi

if [ -d "${IMAGES_DIR}" ]
then
	build_if_needed
fi

docker rmi $(docker images -f "dangling=true" -q)

docker images

# Since we've started the supervisor service in the background,
# we now have nothing holding this process open.
# To make sure the docker container doesn't exit here, we do this:
while true
do
	sleep 1000
done

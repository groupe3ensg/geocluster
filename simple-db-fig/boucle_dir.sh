#!/bin/sh
for i in $(docker ps | grep geoserver:  | grep app_dbgeoser | awk '{print $1}')
	do
	export dir=$(docker inspect $i | grep "\"/geoserver-data_dir\": \"" | awk '{print $2}' | sed "s/\"//g" | sed "s/,//g ")
	echo "chemin: ${dir}"
	sudo cp -r /vagrant/simple-db-fig/tmp2/data_dir ${dir}
done 
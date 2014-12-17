#!/bin/sh
#setting the environment
env.bat
vagrant up
vagrant plugin install vagrant-proxyconf
vagrant ssh
docker run -ti dduportal/fig
#creating the dfig alias
alias dfig="docker run -ti -v \$(pwd):/app -v /vagrant:/vagrant -v /var/run/docker.sock:/var/run/docker.sock dduportal/fig"
#switching to the fig directory
cd /vagrant/simple-db-fig
#creating containers
dfig up -d
#showing the containers already created
dfig ps
#creating the postgis database
dfig run dbserver psql -h dbserver -p 5432 -U postgres -f /vagrant/simple-db-fig/dab.sql
#Name and ip_adress of temporary geoserver
export name_tmp=$(docker ps | grep geoserver: |awk '{print $11}' | grep app_tmp) 
export ip_tmp=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 $name_tmp)
export no_proxy=${no_proxy},${ip_tmp}
#creation du workspace
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<workspace><name>myws2</name></workspace>" http://${ip_tmp}:8080/geoserver/rest/workspaces
#creation d'une postgis database
curl -v -u admin:geoserver -XPOST -T mydb.xml -H "Content-type: text/xml" http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores
curl -v -u admin:geoserver -XGET http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores/dab.xml
#adding a table
curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<featureType><name>shapefile</name></featureType>" http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores/dab/featuretypes
#copying the data_dir in a repertory "tmp"
sudo docker cp $name_tmp:/app/geoserver-2.6.1/data_dir /vagrant/simple-db-fig/tmp
#creating multiple geoservers
dfig scale dbgeoserver=3
#calling the dir_script
sh boucle_dir.sh
#killing the temporary geoserver
docker kill $name_tmp
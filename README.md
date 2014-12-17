geocluster
==========

# Welcome to geocluster Page.
Geocluster is a repository that represent an example of a geoserver cluster. In other words , we will create multiple geoserver containers with the same configuration and a long balacing that switch from one geoserver to another.
We will also create a postgres container that contains the postgis data base .
This page will guide you trough the geoserver cluster example. All you have to do is follow the steps :)
ps: It is supposed that you already have both vagrant and boot2docker.
```
$ env.bat
$ vagrant up
$ vagrant plugin install vagrant-proxyconf
$ vagrant ssh
```

Now that you are in your docker virtual machine, run the script "run.sh".

## The script "run.sh"

In this script:

###pulling fig image
```
$ docker run -ti dduportal/fig
```
###creating the dfig alias
```
$ alias dfig="docker run -ti -v \$(pwd):/app -v /vagrant:/vagrant -v /var/run/docker.sock:/var/run/docker.sock dduportal/fig"
```
###switching to the fig directory
```
$ cd /vagrant/simple-db-fig
```
###creating containers
```
$ dfig up -d
```
###showing the containers already created
```
$ dfig ps
```
Now you have to run the script "env_geoserver_tmp.sh"
## The script "env_geoserver_tmp.sh"
in this script we configure our temporary geoserver container. We will create a workespace , a datastore and add a database. In the end we will copy the data_dir of that container in the temporary repertory in order to copy it later in the data_dir of all the other geoserver containers .   

###creating the postgis database
```
$ dfig run dbserver psql -h dbserver -p 5432 -U postgres -f /vagrant/simple-db-fig/dab.sql
```
###retrieving the name and ip_adress of temporary geoserver
```
$ export name_tmp=$(docker ps | grep geoserver: |awk '{print $11}' | grep app_tmp) 
$ export ip_tmp=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 $name_tmp)
$ export no_proxy=${no_proxy},${ip_tmp}
```
###creation of a workspace
```
$ curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<workspace><name>myws2</name></workspace>" 
http://${ip_tmp}:8080/geoserver/rest/workspaces
```
###creation of a postgis database
```
$ curl -v -u admin:geoserver -XPOST -T mydb.xml -H "Content-type: text/xml" 
http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores
$ curl -v -u admin:geoserver -XGET http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores/dab.xml
```
###adding a table
```
$ curl -v -u admin:geoserver -XPOST -H "Content-type: text/xml" -d "<featureType><name>shapefile</name></featureType>" http://${ip_tmp}:8080/geoserver/rest/workspaces/myws2/datastores/dab/featuretypes
```
#copying the data_dir in a repertory "tmp"
```
$ mkdir tmp
$ sudo docker cp $name_tmp:/app/geoserver-2.6.1/data_dir /vagrant/simple-db-fig/tmp
```
###creating multiple geoservers
```
$ dfig scale dbgeoserver=3
```
###calling the dir_script
```
$ sh boucle_dir.sh
```
###killing the temporary geoserver and deleting the tmp repertory
```
$ docker kill $name_tmp
$ rm -r tmp
```
## The script "boucle_dir.sh"
In this script we run a loop that copy the data_dir of the temporary geoserver in the other geoserver containers.

```
 for i in $(docker ps | grep geoserver:  | grep app_dbgeoser | awk '{print $1}')
	do
	export dir=$(docker inspect $i | grep "\"/geoserver-data_dir\": \"" | awk '{print $2}' | sed "s/\"//g" | sed "s/,//g ")
	echo "chemin: ${dir}"
	sudo cp -r /vagrant/simple-db-fig/tmp2/data_dir ${dir}
done 
```
## The "mydb.xml"
In this file you have to replace in the host the ip adress with the ip adress of your container that you can retrieve by this two commands:

```
dfig ps
docker inspect ${name_of_your_container}
```
## The architecture
![](https://github.com/groupe3ensg/geocluster/blob/master/archi.PNG)

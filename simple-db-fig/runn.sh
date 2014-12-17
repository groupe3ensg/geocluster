#!/bin/sh
#pulling fig image
docker run -ti dduportal/fig
#creating the dfig alias
alias dfig="docker run -ti -v \$(pwd):/app -v /vagrant:/vagrant -v /var/run/docker.sock:/var/run/docker.sock dduportal/fig"
#switching to the fig directory
cd /vagrant/simple-db-fig
#creating containers
dfig up -d
#showing the containers already created
dfig ps
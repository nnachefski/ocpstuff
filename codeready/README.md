##### # 
```
export CODEREADY_TAR=codeready-workspaces-1.2.1.GA-operator-installer.tar.gz
cd ~
wget http://satellite.home.nicknach.net/pub/$CODEREADY_TAR
tar -xzvf $CODEREADY_TAR
cd codeready-workspaces-operator-installer/
./deploy.sh --deploy
```

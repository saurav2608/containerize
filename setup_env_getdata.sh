#!/bin/bash -e
MINICONDA_DIR="$HOME/miniconda3"


if [ -d "$MINICONDA_DIR" ]; then
    echo
    echo "rm -rf "$MINICONDA_DIR""
    rm -rf "$MINICONDA_DIR"
fi

echo "Install Miniconda"
UNAME_OS=$(uname)
if [ "$UNAME_OS" = 'Linux' ]; then
    if [ "$BITS32" = "yes" ]; then
        CONDA_OS="Linux-x86"
    else
        CONDA_OS="Linux-x86_64"
    fi
elif [ "$UNAME_OS" = 'Darwin' ]; then
    CONDA_OS="MacOSX-x86_64"
else
  echo "OS $UNAME_OS not supported"
  exit 1
fi


wget -q "https://repo.continuum.io/miniconda/Miniconda3-latest-$CONDA_OS.sh" -O miniconda.sh
chmod +x miniconda.sh
./miniconda.sh -b

export PATH=$MINICONDA_DIR/bin:$PATH

echo
echo "which conda"
which conda

echo
echo "update conda"
conda config --set ssl_verify false
conda config --set quiet true --set always_yes true --set changeps1 false
conda install pip  # create conda to create a historical artifact for pip & setuptools
conda update -n base conda

echo "conda info -a"
conda info -a


echo "source deactivate"
source deactivate

echo "conda list (root environment)"
conda list
ls -al
pwd



echo
echo "conda env create -q --file=code.yml"
conda env create -q --file=envs/code.yml

echo "activate code"
conda activate code

mlflow models build-docker -m wasbs://artifacts@backendstore.blob.core.windows.net/models/0/0bd78d9b09e3498b825ebdf0a0cf7871/artifacts/model -n "brillio-model"
docker login --username=csaurav --password=$DOCKER_PASSWORD
docker tag 316cb35955a0 csaurav/sc-model:production
docker push csaurav/sc-model:production

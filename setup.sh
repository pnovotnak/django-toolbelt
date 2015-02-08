#!/bin/bash

PROJECT="toolbelt"

#
# This script initializes your Python environment
#

# setup virtual env
echo "Setting up virtual environment (env)"
virtualenv --no-site-packages env
echo "Activating virtual environment"
source env/bin/activate

# install dependencies
pip install --download-cache ~/.pip-cache --allow-external PIL --use-mirrors -r requirements.txt

if [ ! -f $PROJECT/$PROJECT/local_settings.py ]; then
    echo "
Copying default local settings
"
    cp $PROJECT/$PROJECT/local_settings-template.py $PROJECT/$PROJECT/local_settings.py
fi


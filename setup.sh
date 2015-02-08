#!/bin/bash

# https://www.python.org/dev/peps/pep-0008/#package-and-module-names
PROJECT="toolbelt"

#
# This script initializes things
#

# setup virtual env
echo "Setting up virtual environment (env)"
virtualenv --no-site-packages env
echo "Activating virtual environment"
source env/bin/activate

# install dependencies
pip install --download-cache ~/.pip-cache --upgrade -r requirements.txt

# if the project doesn't exist, create it
if [ ! -d $PROJECT ]; then
    django-admin.py startproject $PROJECT
fi

if [ ! -f $PROJECT/$PROJECT/local_settings.py ]; then
    if [ ! -f $PROJECT/$PROJECT/local_settings-template.py ]; then
        # remove secret key from settings
        sed -i '' '/SECRET_KEY/d' toolbelt/toolbelt/settings.py

        # set Debug = False by default
        sed -i '' 's/Debug\ \=\ True/Debug\ \=\ False/' toolbelt/toolbelt/settings.py

        # insert secret key generator
echo "
try:
    SECRET_KEY
except NameError:
    SECRET_FILE = os.path.join(APPS_PATH, '../../secret.txt')
    try:
        SECRET_KEY = open(SECRET_FILE).read().strip()
    except IOError:
        try:
            import random
            SECRET_KEY = ''.join([random.SystemRandom().choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)])
            secret = file(SECRET_FILE, 'w')
            secret.write(SECRET_KEY)
            secret.close()
        except IOError:
            Exception('Please create a %s file with random characters \
            to generate your secret key!' % SECRET_FILE)" >> $PROJECT/$PROJECT/settings.py
    fi
    echo "
Copying default local setting
"
    cp $PROJECT/$PROJECT/local_settings-template.py $PROJECT/$PROJECT/local_settings.py
fi


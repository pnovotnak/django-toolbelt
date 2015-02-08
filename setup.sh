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
        sed -i '' '/SECRET_KEY/d' $PROJECT/$PROJECT/settings.py

        # set Debug = False by default
        sed -i '' 's/DEBUG\ \=\ True/DEBUG\ \=\ False/' $PROJECT/$PROJECT/settings.py

        # local settings import, insert secret key generator
echo "

# Typically this ends up a symlink on prod boxes
STATIC_ROOT = os.path.join(BASE_DIR, '../../static')

MEDIA_URL = '/media/'

# Typically this ends up a symlink on prod boxes
MEDIA_ROOT = os.path.join(BASE_DIR, '../../media')

from local_settings import *

try:
    SECRET_KEY
except NameError:
    SECRET_FILE = os.path.join(BASE_DIR, '../../secret.txt')
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

            # pimp out urls
            sed -i '' '/from\ django\.contrib\ import\ admin/a \
from django.conf.urls.static import static
' $PROJECT/$PROJECT/urls.py
            sed -i '' '/from\ django\.conf\.urls\.static\ import\ static/a \
import settings
' $PROJECT/$PROJECT/urls.py
            sed -i '' '/^)$/ s/$/ \+\ static(settings.MEDIA_URL,\ document_root\=settings\.MEDIA_ROOT)/' $PROJECT/$PROJECT/urls.py

            # create a sensible default local settings template
            echo "# keep only the absolute minimum in this file.

DEBUG = True
TEMPLATE_DEBUG = DEBUG"  >> $PROJECT/$PROJECT/local_settings-template.py
            cp $PROJECT/$PROJECT/local_settings-template.py $PROJECT/$PROJECT/local_settings.py

            while true; do
                read -p "Should I run a syncdb for you? [Y/n]" yn
                case $yn in
                    "" ) $PROJECT/manage.py syncdb; break;;
                    [Yy]* ) $PROJECT/manage.py syncdb; break;;
                    [Nn]* ) break;;
                    * ) echo "Please answer yes or no.";;
                esac
            done

            if [ ! -d .git ]; then
                while true; do
                    read -p "Set up git? [Y/n]" yn
                    case $yn in
                        "" ) git init .; git add .; git commit -am 'initial commit'; break;;
                        [Yy]* ) git init .; git add .; git commit -am 'initial commit'; break;;
                        [Nn]* ) break;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            fi
    else
        echo "
Copying local settings template
"
        cp $PROJECT/$PROJECT/local_settings-template.py $PROJECT/$PROJECT/local_settings.py
    fi
fi

echo

while true; do
    read -p "May I start a development server for you? [Y/n]" yn
    case $yn in
        "" ) $PROJECT/manage.py runserver; break;;
        [Yy]* ) $PROJECT/manage.py runserver; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

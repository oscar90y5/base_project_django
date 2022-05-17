#!/usr/bin/env bash

python manage.py collectstatic --no-input

python manage.py migrate

python manage.py loaddata ./fixtures/*

gunicorn _setup.wsgi -b 0.0.0.0:8000 --reload

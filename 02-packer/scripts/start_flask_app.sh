#!/bin/bash
cd /flask
export TC_DYNAMO_TABLE=Candidates
/usr/local/bin/gunicorn -b 0.0.0.0 app:candidates_app


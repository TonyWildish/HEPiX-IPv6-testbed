#!/bin/sh

cd results/current/
./showme.sh | egrep -v 'Imperial|Glasgow' | grep -v ' 0 0 0 0 0'

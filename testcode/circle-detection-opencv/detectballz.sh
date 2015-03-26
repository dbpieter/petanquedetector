#!/bin/bash

# don't forget to 'chmod a+x ./detectballz.sh'
# maximum 5 seconds for ball detection
timeout 5 python detectballz.py "$@"
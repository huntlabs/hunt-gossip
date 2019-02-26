#!/bin/sh
ulimit -c unlimited
./test -p 6000 &
./test -p 6001 &
./test -p 6002 &
./test -p 6003 &


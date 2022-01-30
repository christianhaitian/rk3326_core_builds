#!/bin/bash
pkill lightshow.sh; lightshow.sh $(expr $(cat /var/local/led.state) - 1) &

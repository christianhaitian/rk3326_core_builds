#!/bin/bash

# This script is Used to notify a user via email or text message
#
# Must have installed msmtp, msmtp-mta, mailutils and s-nail
# Must also configure ~/.mstmprc per https://wiki.archlinux.org/title/msmtp
#
# Usage: notifyme.sh "Text to send in notification"
# Optional: add the word "sms" to the end of the text (in the second position) to also receive a SMS message

tense="has"
arch="$(getconf LONG_BIT)"
echo "${1}" | mail -s "Development Update ${arch}bit" email@domain.com

if [ "${2}" == "sms" ]; then
  echo "${1}" | mail -s "Development Update ${arch}bit" phonenumber@cellularproviderdomain.com
  morethanone="s"
  tense="have"
fi

status=$?
if [ "$status" = 0 ]; then
  echo ""
  echo "Notification${morethanone} ${tense} been sent successfully"
  echo ""
else
  echo ""
  echo "There was a problem sending the notification${morethanone}"
  echo ""
fi

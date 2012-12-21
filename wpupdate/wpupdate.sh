#!/bin/bash
clear
echo "
################################################################################
##		  NearlyFreeSpeech.Net WordPress Update Script		      ##
##		     (C) Mischif 2011, CC BY-NC-SA Licensed		      ##
##     If this script saves you five minutes, why not send me five bucks?     ##
##  Shoot Paypal and (preferably) Dwolla donations to: donate@mischivous.com  ##
## Thanks to Sivet and Viper007Bond for helping with tag parsing/DB upgrading ##
################################################################################
"

WPDIR=$1
ID=`id -u`
USER='wpupdate'
PASSWORD="PASSWORD"
UPDATEADDR='http://www.example.com/wpupdate/'
RECLAIMADDR="$UPDATEADDR"gimmemyfilesback.cgi
RESETADDR="$UPDATEADDR"setpermissions.cgi
TAGSURL='http://core.svn.wordpress.org/tags/'
STABLETAG=`curl -s $TAGSURL | awk -F '">' '{print $2}' | awk -F"/<" '{print $1}' | egrep "^[0-9].[0-9]" | sort -n | tail -n 1`

if [ $STABLETAG == '' ]
	then
	echo "Unable to reach repo, check internet connection and try again..."
	exit 1
	fi

if [[ ! `curl -s --digest --user $USER:$PASSWORD "$RECLAIMADDR?$WPDIR"` == 0 ]] ; then
	echo "Please file a support request to reclaim files"
#	exit 1
	fi

if [[ -d "$WPDIR"wp-content/cache/ ]]
	then
	rm -rf "$WPDIR"wp-content/cache/
	fi

if [[ -d "$WPDIR"wp-content/plugins/widgets/ ]]
	then
	rm -rf "$WPDIR"wp-content/plugins/widgets/
	fi

echo "Updating to Wordpress $STABLETAG..."
svn sw -q $TAGSURL$STABLETAG $WPDIR

echo "Setting permissions..."
find $WPDIR -path "*.svn" -prune -o -user $ID -exec chgrp $ID {} +
find "$WPDIR"wp-admin/ -path "*.svn" -prune -o -user $ID -exec chgrp web {} +
find "$WPDIR"wp-content/ -path "*.svn" -prune -o -mindepth 1 -user $ID -exec chgrp web {} +
find $WPDIR -path "*.svn" -prune -o -user $ID -type d -exec chmod 755 {} +
find $WPDIR -path "*.svn" -prune -o -user $ID -type f -exec chmod 644 {} +
find "$WPDIR"wp-content/ -path "*.svn" -prune -o -mindepth 1 -user $ID -exec chmod 775 {} +
if [[ ! `curl -s --digest --user $USER:$PASSWORD $RESETADDR?$WPDIR` == 0 ]] ; then
	echo "Please file a support request to reclaim files"
	fi

echo "Upgrading database..."
php -f upgradedb.php "$WPDIR"
#TODO: one-line PHP command that gets rid of the shim

echo "Done! Head to /wp-admin/upgrade.php from your browser to finish update."
exit 0

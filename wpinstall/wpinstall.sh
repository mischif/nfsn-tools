#!/bin/bash
clear
echo "
################################################################################
##			 NFS.N WordPress Install Tool			      ##
##		     (C) Mischif 2012, CC BY-NC-SA Licensed		      ##
##     If this script saves you five minutes, why not send me five bucks?     ##
##  Shoot Paypal and (preferably) Dwolla donations to: donate@mischivous.com  ##
##   Use an absolute path to desired location; remember the trailing slash!   ##
################################################################################
"
STUB="<?php\n\nrequire_once(\$_SERVER['NFSN_SITE_ROOT'] . '/protected/wp-config.php');\n\n\n// Absolute path to the WordPress directory.\nif ( !defined('ABSPATH') )\n\tdefine('ABSPATH', dirname(__FILE__) . '/');\n\n// Sets up WordPress vars and included files.\nrequire_once(ABSPATH . 'wp-settings.php');\n\n?>"
LN=45
WPDIR=$1
TAGSURL='http://core.svn.wordpress.org/tags/'
STABLETAG=`curl -s $TAGSURL | awk -F '">' '{print $2}' | awk -F"/<" '{print $1}' | egrep "^[0-9].[0-9]" | sort -n | tail -n 1`

if [ $STABLETAG == '' ]
	then
	echo "Unable to reach WordPress repositories, check internet connection and retry..."
	exit 1
	fi

read -erp "Has a database been initialized and a user created ([y]es/[n]o)? " -n 1 HASDB
	if [[ $HASDB =~ ^[Nn]$ ]] ; then
		echo "Please create a database & user for WordPress before running this script"
		exit 1
	elif [[ !$HASDB =~ ^[Yy]$ ]] ; then
		echo "Invalid entry"
		exit 1
	fi

read -erp "Is this installation's primary use WordPress development ([y]/[n])? " -n 1 DEVEL
	if [[ $DEVEL =~ ^[Yy]$ ]] ; then
		DEVEL=true

		read -erp "Will you be modifying built-in WordPress CSS/JS ([y]/[n])? " -n 1 WPSCRIPTS
		if [[ $WPSCRIPTS =~ ^[Yy]$ ]] ; then
			WPSCRIPTS=true
		elif [[ $WPSCRIPTS =~ ^[Nn]$ ]] ; then
			WPSCRIPTS=false
		else
			echo "Invalid entry"
			exit 1
		fi

	elif [[ $DEVEL =~ ^[Nn]$ ]] ; then
		DEVEL=false
	else
		echo "Invalid entry"
		exit 1
	fi

read -erp "Allow plugin/theme updates from admin panel ([n] safer, [y] more convenient)? " -n 1 UPDATES
	if [[ $UPDATES =~ ^[Yy]$ ]] ; then
		UPDATES=true
	elif [[ $UPDATES =~ ^[Nn]$ ]] ; then
		UPDATES=false
	else
		echo "Invalid entry"
		exit 1
	fi

read -erp "Allow plugin/theme editing in admin panel ([n] safer, [y] more convenient)? " -n 1 EDITS
	if [[ $EDITS =~ ^[Yy]$ ]] ; then
		EDITS=true
	elif [[ $EDITS =~ ^[Nn]$ ]] ; then
		EDITS=false
	else
		echo "Invalid entry"
		exit 1
	fi

read -erp "Desired table prefix (alphanum + underscore, blank for default)? " DBPREFIX
	if [[ $DBPREFIX == "" ]] ; then
		DBPREFIX="wp_"
	fi

read -erp "What is the database server name (e.g. example.db)? " DSN

read -erp "What is the name of the database? " DBNAME

read -erp "What is the name of the database user? " DBUSER

read -ersp "What is the password of the database user? " DBPASSWD; clear

echo "		INSTALLATION SETTINGS CONFIRMATION"; echo
echo "Installation Folder:			$WPDIR"
echo "Development Install:			$DEVEL"
if [[ $WPSCRIPTS ]] ; then
echo "Modifying WordPress JS/CSS:		$WPSCRIPTS"
fi
echo "Database Server Name:			$DSN"
echo "Database Name:				$DBNAME"
echo "Database User Name:			$DBUSER"
echo "Database Table Prefix:			$DBPREFIX"
	echo "Updates From Admin Panel:		$UPDATES"
echo "Theme/Plugin Updates From Admin Panel:	$EDITS"; echo


read -erp "Are these values correct ([y]/[n])? " -n 1 CONFIRM
	if [[ $CONFIRM =~ ^[Nn]$ ]] ; then
		echo "Please rerun this script with correct values"
		exit 1
	fi

echo "Grabbing WordPress $STABLETAG..."
svn co -q $TAGSURL$STABLETAG $WPDIR

echo "Configuring WordPress..."
sed -i '' "s/database_name_here/$DBNAME/g" "$WPDIR"wp-config-sample.php
sed -i '' "s/username_here/$DBUSER/g" "$WPDIR"wp-config-sample.php
sed -i '' "s/password_here/$DBPASSWD/g" "$WPDIR"wp-config-sample.php
sed -i '' "s/localhost/$DSN/g" "$WPDIR"wp-config-sample.php
sed -i '' "s/wp_/$DBPREFIX/g" "$WPDIR"wp-config-sample.php
sed -i '' "s/false/$DEVEL/g" "$WPDIR"wp-config-sample.php
sed -i '' "82i\\ 
	define('WP_TEMP_DIR', $_SERVER['NFSN_SITE_ROOT'] . 'protected');" "$WPDIR"wp-config-sample.php
sed -i '' "82i\\
	define('FS_CHMOD_DIR', 0775);
" "$WPDIR"wp-config-sample.php
sed -i '' "82i\\
	define('FS_CHMOD_FILE', 0664);
" "$WPDIR"wp-config-sample.php
sed -i '' "82i\\
	define('FS_METHOD', 'direct');
" "$WPDIR"wp-config-sample.php

if [[ $EDITS == "false" ]] ; then
sed -i '' "82i\\
	define('DISALLOW_FILE_EDIT',true);
" "$WPDIR"wp-config-sample.php
fi

if [[ $UPDATES == "false" ]] ; then
sed -i '' "82i\\
	define('DISALLOW_FILE_MODS',true);
" "$WPDIR"wp-config-sample.php
fi

if [[ $WPSCRIPTS == "true" ]] ; then
sed -i '' "82i\\
	define('SCRIPT_DEBUG', true);
" "$WPDIR"wp-config-sample.php
fi

curl -s https://api.wordpress.org/secret-key/1.1/salt | while read LINE
	do
	sed -i '' "$LN"c"\\
		$LINE
		" "$WPDIR"wp-config-sample.php
	LN=$((LN+1))
	done

FILENAME="wp-config-"`echo $DBNAME | tr -cd [:alnum:]`"-"`echo $DBPREFIX | tr -cd [:alnum:]`".php"
STUB=`echo $STUB | sed "s/wp-config.php/$FILENAME/g"`
LASTLINE=$((`wc "$WPDIR"wp-config-sample.php | awk {'print $1'}` - 7))
head -n $LASTLINE "$WPDIR"wp-config-sample.php > /home/protected/$FILENAME
rm "$WPDIR"wp-config-sample.php
echo -e $STUB > "$WPDIR"wp-config.php


echo "Setting permissions..."

find $WPDIR -path "*.svn" -prune -o -type d -exec chmod 755 {} +
find $WPDIR -path "*.svn" -prune -o -type f -exec chmod 644 {} +
chgrp web "$WPDIR"wp-admin/admin.php "$WPDIR"wp-admin/admin-header.php "$WPDIR"wp-admin/update.php "$WPDIR"wp-admin/media-new.php "$WPDIR"wp-admin/media-upload.php

if [[ $EDITS == "true" ]] ; then
	chgrp web "$WPDIR"wp-admin/plugin-editor.php "$WPDIR"wp-admin/theme-editor.php
fi

if [[ $UPDATES == "true" ]] ; then
	chgrp web "$WPDIR"wp-admin/plugins.php "$WPDIR"wp-admin/themes.php
	chgrp -R "$WPDIR"wp-content/
fi

echo "Done! Head to "$WPDIR"wp-admin/install.php from your web browser to finish up."
exit 0

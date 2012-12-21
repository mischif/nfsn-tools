<?php

################################################################################
##			 NFS.N Wordpress Upgrade Script			      ##
##		     (C) Mischif 2011, CC BY-NC-SA Licensed		      ##
##     If this script saves you five minutes, why not send me five bucks?     ##
##  Shoot Paypal and (preferably) Dwolla donations to: donate@mischivous.com  ##
## Thanks to Sivet and Viper007Bond for helping with tag parsing/DB upgrading ##
################################################################################

define( 'WP_INSTALLING', true );
require_once( $argv[1] . 'wp-load.php' );
timer_start();
require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );
delete_site_transient('update_core');
wp_upgrade();
die();

?>

#!/bin/bash

# WPI ENV
# by DimaMinka (https://dima.mk)
# https://github.com/wpi-pw/app

# Get config files and put to array
wpi_confs=()
for ymls in wpi-config/*
do
  wpi_confs+=("$ymls")
done

# Get wpi-source for yml parsing, noroot, errors etc
source <(curl -s https://raw.githubusercontent.com/wpi-pw/template-workflow/master/wpi-source.sh)

cur_env=$1
cur_wpi="wpi_env_${cur_env}_"
app_path=${PWD}

printf "${GRN}=====================================${NC}\n"
printf "${GRN}.env init for "$(wpi_key "app_host")"${NC}\n"
printf "${GRN}=====================================${NC}\n"

if [ -f "${PWD}/.env" ]; then
  mv $app_path/.env $app_path/.env.old
fi

echo "DB_NAME=$(wpi_key "db_name")" >> $app_path/.env
echo "DB_USER=$(wpi_key "db_user")" >> $app_path/.env
echo "DB_PASSWORD=$(wpi_key "db_pass")" >> $app_path/.env

echo "" >> $app_path/.env

echo "# Optional variables" >> $app_path/.env
echo "# DB_HOST=localhost" >> $app_path/.env
echo "DB_PREFIX=$(wpi_key "db_prefix")" >> $app_path/.env

echo "" >> $app_path/.env

echo "WP_ENV=$cur_env" >> $app_path/.env
echo "WP_HOME=$(wpi_key "app_protocol")://$(wpi_key "app_host")" >> $app_path/.env
echo "WP_SITEURL=\${WP_HOME}/wp" >> $app_path/.env

echo "" >> $app_path/.env

# download salts and save to file
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > $app_path/salts.txt
# parse the key-values into variables
echo "AUTH_KEY=\"$(cat $app_path/salts.txt |grep -w AUTH_KEY | cut -d \' -f 4)\"" >>  $app_path/.env
echo "SECURE_AUTH_KEY=\"$(cat $app_path/salts.txt |grep -w SECURE_AUTH_KEY | cut -d \' -f 4)\"" >>  $app_path/.env
echo "LOGGED_IN_KEY=\"$(cat $app_path/salts.txt |grep -w LOGGED_IN_KEY | cut -d \' -f 4)\"" >>  $app_path/.env
echo "NONCE_KEY=\"$(cat $app_path/salts.txt |grep -w NONCE_KEY | cut -d \' -f 4)\"" >>  $app_path/.env
echo "AUTH_SALT=\"$(cat $app_path/salts.txt |grep -w AUTH_SALT | cut -d \' -f 4)\"" >>  $app_path/.env
echo "SECURE_AUTH_SALT=\"$(cat $app_path/salts.txt |grep -w SECURE_AUTH_SALT | cut -d \' -f 4)\"" >>  $app_path/.env
echo "LOGGED_IN_SALT=\"$(cat $app_path/salts.txt |grep -w LOGGED_IN_SALT | cut -d \' -f 4)\"" >>  $app_path/.env
echo "NONCE_SALT=\"$(cat $app_path/salts.txt |grep -w NONCE_SALT | cut -d \' -f 4)\"" >>  $app_path/.env
# remove key file
rm $app_path/salts.txt

echo "" >> $app_path/.env

# extra custom config
echo "EXTRA_FILES=$(wpi_yq extra.files)" >> $app_path/.env
echo "WPI_HOST=$(wpi_key "app_host")" >> $app_path/.env
echo "WP_POST_REVISIONS=$(wpi_yq extra.wp_post_revisions)" >> $app_path/.env
echo "AUTOSAVE_INTERVAL=$(wpi_yq extra.autosave_interval)" >> $app_path/.env
echo "WP_MEMORY_LIMIT=$(wpi_yq extra.wp_memory_limit)" >> $app_path/.env
echo "WP_MAX_MEMORY_LIMIT=$(wpi_yq extra.wp_max_memory_limit)" >> $app_path/.env
echo "DISABLE_WP_CRON=$(wpi_yq extra.wp_cron_disable)" >> $app_path/.env

echo "" >> $app_path/.env

# extra custom config for production
echo "MEDIA_TRASH=$(wpi_yq extra.media_trash)" >> $app_path/.env
echo "EMPTY_TRASH_DAYS=$(wpi_yq extra.empty_trash_days)" >> $app_path/.env

echo "" >> $app_path/.env

# extra multisite config
echo "EXTRA_MULTISITE=$(wpi_yq extra.multisite)" >> $app_path/.env

echo "" >> $app_path/.env

# WP Mail SMTP by WPForms config
echo "WPMS_ON=$(wpi_yq extra.wpms_on)" >> $app_path/.env
echo "WPMS_SMTP_PASS=$(wpi_yq extra.wpms_smtp_pass)" >> $app_path/.env

echo "" >> $app_path/.env

# WP Rocket license config
echo "WP_ROCKET_EMAIL=$(wpi_yq extra.wp_rocket_email)" >> $app_path/.env
echo "WP_ROCKET_KEY=$(wpi_yq extra.wp_rocket_key)" >> $app_path/.env

echo "" >> $app_path/.env

# AdvancedCustomFields Pro - license config
echo "ACF_PRO_UPDATE_LICENSE=$(wpi_yq extra.acf_pro_update_license)" >> $app_path/.env

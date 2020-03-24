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

cur_env=$(cur_env)
cur_wpi="wpi_env_${cur_env}_"
app_path=${PWD}

printf "${GRN}======================================${NC}\n"
printf "${GRN} .env init for "$(wpi_key "app_host")"${NC}\n"
printf "${GRN}======================================${NC}\n"

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

echo "" >> $app_path/.env

mapfile -t env_keys < <( wpi_yq "env.$cur_env.custom" 'keys' )
# Get all custom configs and add to env
for i in "${!env_keys[@]}"
do
  echo "${env_keys[$i]}=$(wpi_yq "env.$cur_env.custom.${env_keys[$i]}")" >> $app_path/.env
done

printf "${GRN}======================================${NC}\n"
printf "${GRN} Config alias's in the wp-cli.yml     ${NC}\n"
printf "${GRN}======================================${NC}\n"
# Clean wp-cli.yml before insert alias's
> $app_path/wp-cli.yml
# Restore basic setup for bedrock
echo "path: web/wp" >> $app_path/wp-cli.yml
echo "server:" >> $app_path/wp-cli.yml
echo "  docroot: web" >> $app_path/wp-cli.yml
# Get top keys from env config, local excluded
mapfile -t env_alias < <(wpi_yq "env" "top_keys")
# Make wp cli alias in wp-cli.yml from for env config
for i in "${!env_alias[@]}"
do
  # default vars for user, ip, dir
  a_user=$(wpi_yq "env.${env_alias[$i]}.app_user")
  a_ip=$(wpi_yq "env.${env_alias[$i]}.app_ip")
  a_dir=$(wpi_yq "env.${env_alias[$i]}.app_dir")
  # check the vars and if not local
  if [[ $a_user && $a_ip && $a_dir ]]; then
    echo >> $app_path/wp-cli.yml
    # set alias via env
    echo "@${env_alias[$i]}:" >> $app_path/wp-cli.yml
    # add ssh config for current alias
    echo "  ssh: $a_user@$a_ip:${a_dir%/}" >> $app_path/wp-cli.yml
  fi
done
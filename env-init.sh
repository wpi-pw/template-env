#!/bin/bash

# Init - Wp Pro Club
# by DimaMinka (https://dimaminka.com)
# https://github.com/wp-pro-club/init

source ${PWD}/lib/app-init.sh

printf "${GRN}====================================${NC}\n"
printf "${GRN}.env init for $conf_app_env_app_host${NC}\n"
printf "${GRN}====================================${NC}\n"

if [ -f "$APP_PATH/.env" ]; then
  mv $APP_PATH/.env $APP_PATH/.env.old
fi

echo "DB_NAME=$conf_app_env_db_name" >> $APP_PATH/.env
echo "DB_USER=$conf_app_env_db_user" >> $APP_PATH/.env
echo "DB_PASSWORD=$conf_app_env_db_pass" >> $APP_PATH/.env

echo "" >> $APP_PATH/.env

echo "# Optional variables" >> $APP_PATH/.env
echo "# DB_HOST=localhost" >> $APP_PATH/.env
echo "DB_PREFIX=$conf_app_env_db_prefix" >> $APP_PATH/.env

echo "" >> $APP_PATH/.env

echo "WP_ENV=staging" >> $APP_PATH/.env
echo "WP_HOME=http://${conf_app_env_app_host}" >> $APP_PATH/.env
echo "WP_SITEURL=\${WP_HOME}/wp" >> $APP_PATH/.env

echo "" >> $APP_PATH/.env

echo "# Generate your keys here: https://roots.io/salts.html" >> $APP_PATH/.env
echo "AUTH_KEY='generateme'" >> $APP_PATH/.env
echo "SECURE_AUTH_KEY='generateme'" >> $APP_PATH/.env
echo "LOGGED_IN_KEY='generateme'" >> $APP_PATH/.env
echo "NONCE_KEY='generateme'" >> $APP_PATH/.env
echo "AUTH_SALT='generateme'" >> $APP_PATH/.env
echo "SECURE_AUTH_SALT='generateme'" >> $APP_PATH/.env
echo "LOGGED_IN_SALT='generateme'" >> $APP_PATH/.env
echo "NONCE_SALT='generateme'" >> $APP_PATH/.env

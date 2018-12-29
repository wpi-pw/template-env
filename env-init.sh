#!/bin/bash

# Init - Wp Pro Club
# by DimaMinka (https://dimaminka.com)
# https://github.com/wp-pro-club/init

# DEFINE COLORS
RED='\033[0;31m' # error
GRN='\033[0;32m' # success
BLU='\033[0;34m' # task
BRN='\033[0;33m' # headline
NC='\033[0m' # no color

APP_PATH=${PWD}/..
INIT_CONF=$APP_PATH/default-config.yml
if [[ -f $APP_PATH/custom-config.yml ]]; then
	INIT_CONF=$APP_PATH/custom-config.yml
fi

# YAML parser function
function parse_yaml() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, $3);
        }
    }' | sed 's/_=/+=/g'
}

# READ CONFIG
eval $(parse_yaml $INIT_CONF "conf_")

printf "${GRN}====================================${NC}\n"
printf "${GRN}.env init for $conf_app_env_app_host${NC}\n"
printf "${GRN}====================================${NC}\n"

if [ -f "$APP_PATH/.env" ]; then
  mv $APP_PATH/.env $APP_PATH/.env.old
fi

echo "DB_NAME=$conf_app_env_db_name" >> $APP_PATH/.env
echo "DB_USER=$conf_app_env_db_user" >> $APP_PATH/.env
echo "DB_PASS=$conf_app_env_db_pass" >> $APP_PATH/.env

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

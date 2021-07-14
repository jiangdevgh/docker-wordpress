tag=""
url="https://blog.jiang.dev"
title="Jiang'""s Blog"
admin="kou"
email="koumuu@outlook.com"
pw="123456"

while [ $# -gt 1 ]; do
  if [[ $1 == *"--"* ]]; then
    v="${1/--/}"
    declare "$v"="$2"
    shift
    shift
  else
    break
  fi
done

tag=$1
required=(tag title admin email pw)
for name in "${required[@]}"; do
  if [[ ${!name} == "" ]]; then
    echo "$name is missing"
    exit
  else
    echo "$name=${!name}"
  fi
done

# generate .env
printf 'WORDPRESS_URL="%q"\nWORDPRESS_TITLE="%q"\nWORDPRESS_ADMIN="%q"\nWORDPRESS_EMAIL="%q"\nWORDPRESS_INITPW="%q"' "$url" "$title" "$admin" "$email" "$pw" > ./wordpress/.env

# build image
docker build -t "wptest" \
             -t "jiangdev/wordpress:${tag}" \
             -t "jiangdev/wordpress:latest" \
             ./wordpress

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

docker build --build-arg WORDPRESS_URL="$url" \
              --build-arg WORDPRESS_TITLE="$title" \
              --build-arg WORDPRESS_ADMIN="$admin" \
              --build-arg WORDPRESS_EMAIL="$email" \
              --build-arg WORDPRESS_INITPW="$pw" \
              -t "jiangdev/wordpress:${tag}" \
              -t "jiangdev/wordpress:latest" \
              ./wordpress

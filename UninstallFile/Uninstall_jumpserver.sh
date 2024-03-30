#!/bin/bash


docker_id=($(docker ps -aq --filter "name=jms.*"))
images_id=()
for i in "${docker_id[@]}"
do
  images_id+=($(docker inspect -f '{{.Image}}' "$i" | awk -F':' '{print $2}'))
done
          if [ "${#docker_id@}" -ne 0 ]; then
              for y in "${docker_id[@]}"
              do
                 docker stop "$y"
                 docker rm "$y"
              done
          fi
          if [ "${#images_id[@]}" -ne 0 ]; then
              for t in "${images_id[@]}"
              do
                docker rmi "$t"
              done
          fi
if [ -d /opt/jumpserver/ ]; then
    rm -rf /opt/jumpserver/*
fi

echo "卸载完成"
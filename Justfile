version := `git describe --tags | sed "s/\\([^-]*\\)-.*/\\1/"`
docker_repo := "docker.moscow.alfaintra.net"
image_name := "docker-mongodb-mms-agent"
image_full_name := docker_repo + "/" + image_name + ":" + version

# build image
build:
  docker build -t {{image_full_name}} -f Dockerfile .

# run image with some envs
run:
  docker run --name image_name --rm \
  -e MONGO_MMS_API_KEY=somekey \
  -e MONGO_MMS_GROUP_ID=someid \
  -e MONGO_MMS_BASE_URL=http://somehost:7070 \
  {{image_full_name}}

dive:
  dive {{image_full_name}}

# clean everything after builds
clean: containers-clean-all images-clean-unused remove-images
  docker ps -a
  docker images
# clean unused images
images-clean-unused:
  docker images | grep none | awk '{ print $3 }' | xargs -I{} docker rmi {}
# remove all containers
containers-clean-all:
  docker ps -aq | xargs -I{} docker rm -f {}
# remove specific image
remove-image image=(image_full_name):
  docker rmi {{image}}
# remove all linked images
remove-images:
  @docker images | grep {{image_name}} | awk '{ print $3 }' | xargs -I{} docker rmi {}
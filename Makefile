#!make
CONTAINER_NAME		= mongodb-mms-agent-1
IMAGE_NAME				= mongodb-mms-agent
IMAGE_VERSION			= $(shell git describe --tags | sed 's/\([^-]*\)-.*/\1/')
DEFAULT_LOG_LINES = 20

MMS_GROUP_ID			= 5b9d6afeba7b650092f1ff28
MMS_API_KEY				=	5b9d8d2cba7b650092f2235d4981c93652fe4fb49f7fee712f5007f7
MMS_BASE_URL			= http://localhost:8080

define START_CMD
	--network="host" \
	--env "MMS_GROUP_ID=${MMS_GROUP_ID}" \
	--env "MMS_API_KEY=${MMS_API_KEY}" \
	--env "MMS_BASE_URL=${MMS_BASE_URL}" \
	docker.moscow.alfaintra.net/${IMAGE_NAME}:${IMAGE_VERSION}
endef
export START_CMD

all: build clean start-service logs

build:
	@./gradlew build $1>/dev/null
	@echo "BUILD SUCCESS"
version:
	@echo ${IMAGE_VERSION}
cmd:
	@echo docker run -it --name ${CONTAINER_NAME} ${START_CMD}

logs:
	@docker logs ${CONTAINER_NAME} --follow
logs-backup:
	@tail -n${DEFAULT_LOG_LINES} /var/log/${CONTAINER_NAME}/backup-daemon.log
logs-manager:
	@tail -n${DEFAULT_LOG_LINES} /var/log/${CONTAINER_NAME}/ops-manager.log

clean:
	- @docker rm -f ${CONTAINER_NAME}
full-clean: remove-logs remove-conf clean
cert-clean:
	@sudo rm -rf /etc/mongodb-ops-manager/cert

remove-logs:
	@sudo rm -rf /var/log/${CONTAINER_NAME}
remove-conf:
	@sudo rm -rf /etc/${CONTAINER_NAME}/conf

full-start: build full-clean start-service logs
start-service:
	@docker run -d --name ${CONTAINER_NAME} ${START_CMD}
start:
	@docker run -it --name ${CONTAINER_NAME} ${START_CMD}
start-bash:
	@docker run -it --name ${CONTAINER_NAME} ${START_CMD} bash
bash:
	@docker exec -it ${CONTAINER_NAME} bash

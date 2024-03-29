.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: qemu-raspberry-start
qemu-raspberry-start: ## Start a local Raspberry os image in docker to act as testing target
	(cd docker-qemu-raspberry && docker compose up -d qemu-raspberry)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY: qemu-raspberry-start-persistent
qemu-raspberry-start-persistent: ## Start a local Raspberry os image in docker to act as testing target using persistent disk
	(cd docker-qemu-raspberry && mkdir -p sdcard && docker compose up -d qemu-raspberry-persistent)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY: qemu-raspberry-logs
qemu-raspberry-logs: ## Show logs for Raspberry pi docker
	@echo "NOTE: Use CTRL-C to stop tailing logs"
	(cd docker-qemu-raspberry && docker compose logs -f)

.PHONY: qemu-raspberry-stop
qemu-raspberry-stop: ## Stop local Raspberry pi docker
	(cd docker-qemu-raspberry && docker compose stop)

.PHONY: qemu-raspberry-shell
qemu-raspberry-shell: ## Open SSH shell to local Raspberry
	sshpass -p raspberry ssh -p 5022 pi@localhost

.PHONY: docker-debian-start
docker-debian-start: ## Start local Debian in docker
	(cd docker-debian && docker compose up --build -d)

.PHONY: docker-debian-stop
docker-debian-stop: ## Stop local Debian docker
	(cd docker-debian && docker compose stop)

.PHONY: docker-debian-shell
docker-debian-shell: ## Open SSH shell to local Debian
	sshpass -p root ssh -p 5022 root@localhost

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: local-raspberry-start
local-raspberry-start: ## Start a local Raspberry os image in docker to act as testing target
	(cd local-raspberry-in-docker && docker compose up -d local-raspberry)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY: local-raspberry-start-persistent
local-raspberry-start-persistent: ## Start a local Raspberry os image in docker to act as testing target using persistent disk
	(cd local-raspberry-in-docker && mkdir -p sdcard && docker compose up -d local-raspberry-persistent)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY: local-raspberry-logs
local-raspberry-logs: ## Show logs for Raspberry pi docker
	@echo "NOTE: Use CTRL-C to stop tailing logs"
	(cd local-raspberry-in-docker && docker compose logs -f)

.PHONY: local-raspberry-stop
local-raspberry-stop: ## Stop local Raspberry pi docker
	(cd local-raspberry-in-docker && docker compose stop)

.PHONY: local-raspberry-shell
local-raspberry-shell: ## Open SSH shell ro local Raspberry
	sshpass -p raspberry ssh -p 5022 pi@localhost

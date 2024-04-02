.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:test-qemu-start
test-qemu-start: ## Start a local Raspberry os image in docker to act as testing target
	(cd test/docker-qemu-raspberry && docker compose up -d qemu-raspberry)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY:test-qemu-start-persistent
test-qemu-start-persistent: ## Start a local Raspberry os image in docker to act as testing target using persistent disk
	(cd test/docker-qemu-raspberry && docker compose up -dtest-qemu-persistent)
	@echo "NOTE: On first start it'll take over 1 minute before container is ready"

.PHONY:test-qemu-clear-persistent
test-qemu-clear-persistent: ## Stop and clear persistence
	(cd test/docker-qemu-raspberry && docker compose down -v)

.PHONY:test-qemu-logs
test-qemu-logs: ## Show logs for Raspberry pi docker
	@echo "NOTE: Use CTRL-C to stop tailing logs"
	(cd test/docker-qemu-raspberry && docker compose logs -f)

.PHONY:test-qemu-test
test-qemu-test: ## Test against Raspberry pi docker
	ansible-playbook -i test/docker-qemu-raspberry-hosts.yml main.yml

.PHONY:test-qemu-stop
test-qemu-stop: ## Stop local Raspberry pi docker
	(cd test/docker-qemu-raspberry && docker compose stop)

.PHONY: test-debian-start
test-debian-start: ## Start local Debian in docker
	(cd test/docker-debian && docker compose up --build -d --remove-orphans)

.PHONY: test-debian-stop
test-debian-stop: ## Stop local Debian docker
	(cd test/docker-debian && docker compose down -v)

.PHONY: test
test: ## Test against local Debian in docker
	ansible-playbook -i test/docker-debian-hosts.yml test/main.yml $(PARAMS)

.PHONY: test-root
test-root: ## Test against local Debian in docker as root user
	ansible-playbook -i test/docker-debian-root-hosts.yml test/main.yml

.PHONY: test-shell
test-shell: ## Open SSH shell to test docker
	sshpass -p raspberry ssh -p 5022 pi@localhost



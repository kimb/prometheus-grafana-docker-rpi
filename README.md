# Ansible role for deploying Prometheus and Grafana as docker containers.

Intended for easy (re-)deployment and updating of Prometheus monitoring and
Grafana visualization.

Can be used local deployment for most linux and Raspberry Pi systems.

Deploys docker compose with containers:

* [Prometheus](https://hub.docker.com/r/prom/prometheus/)
* [Grafana](https://hub.docker.com/r/grafana/grafana-oss)
* (optional) [Node exporter](https://github.com/prometheus/node_exporter) to
  monitor the host node using Prometheus
* (optional)
  Grafana [ntfy.sh integration](https://github.com/academo/grafana-alerting-ntfy-webhook-integration)

It will also:

1. Ensure docker is installed
2. Automatically provision a Prometheus datasource into Grafana
3. (optional) Add node_exporter scraping to Prometheus and provision Grafana
   with dashboard & alerts.
4. (optional) Automatically provision a [ntfy.sh](https://ntfy.sh/) alerting
   contact point into Grafana.
5. Start/Update the Docker composition.

After that:

* Grafana is available on port `3000`: http://localhost:3000
* Prometheus is available on port `9090` (use `http://prometheus:9090` from
  Grafana)

## Usage

Create a hosts file targeting your Raspberry Pi. For example
`raspberry-hosts.yml` containing:

```yaml
default:
  hosts:
    my-raspberry.local:
      ansible_user: pi
      ansible_password: raspberry
```

Create `requirements.yml`:

```yaml
---
roles:
  - name: geerlingguy.docker
  - name: kimb.prometheus_grafana
    src: ssh://git@github.com/kimb/prometheus-grafana-docker-rpi.git
    version: master
    scm: git
```

Install it: `ansible-galaxy roles install -r requirements.yml`

Then use it in your `main.yml` playbook:

```yaml
- hosts: all
  vars:
    prometheus_scrape_configs:
      - job_name: 'spring-boot-actuator'
        scrape_interval: 30s
        static_configs:
          - targets:
              - 'prod-server1.example.com:8080'
              - 'prod-server2.example.com:8080'
        metrics_path: '/actuator/prometheus'
  roles:
    - kimb.prometheus_grafana
```

And finally run it:

```shell
$ ansible-playbook -i raspberry-hosts.yml main.yml
```

## Options

You can set the following Ansible variables for this role to alter the resulting
setup:

* `prometheus_scrape_configs` Prometheus config where to obtain data (default:
  undefined)
  * note: if `node_exporter_enable` is true, node_exporter scraping is done
    automatically
* `prometheus_retention_time` max time to preserve data (default: 400d)
* `prometheus_retention_size` max size of time series database (default:
  undefined)
* `node_exporter_enable` should a node exporter container be deployed (default:
  true)
* `prometheus_grafana_dir` to set where docker-compose.yml is installed.
  (default: $HOME/prometheus_grafana)
* `grafana_anonymous` should access to grafana without login be permitted (
  default: false)
* `grafana_anonymous_edit` should anonymous users be permitted to modify
  dashboards (default: false)
* `grafana_admin_password` to automatically set initial admin password
* `ntfy_topic` topic name to automatically create container doing Grafana
  webhook -> ntfy.sh integration. Provision it into Grafana as an alert
  contact point. (default: undefined)
* `domain_name` domain to use for Grafana, notifications and traefik (
  default: 'localhost')
* `grafana_labels` list of labels to use. Allows customization of e.g. traefik
  config (default: undefined)

Change this Ansible role operation using variables:

* `docker_install` assume docker is already installed (default: false)
* `docker_pull` set to "always" to update container images (default: "policy")

## Security

* Grafana and Prometheus containers don't support execution using an arbitrary
  user id. But as the docker socket isn't bind-mounted into these containers,
  they should be isolated from the main system.
* To monitor for image updates, consider installing a monitoring tool
  like https://crazymax.dev/diun/ and when updates are published re-running your
  playbook with `docker_pull: "always"`.

## Dependencies

* geerlingguy.docker: To install docker to target host,
  see [ansible-galaxy](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/docker/)
  or [github](https://github.com/geerlingguy/ansible-role-docker)

## Testing locally (for development)

This project provides two ways to locally test and run the deployment.
Using qemu to emulate a raspberry or a plain debian:bookworm image.

* To test using qemu executed in a container (currently not working due
  to [an issue](https://github.com/carlosperate/docker-qemu-rpi-os/issues/6)):

  ```shell
  $ make test-qemu-start
  $ make test-qemu-logs
  (CTRL-c when ready)
  $ make test-qemu-test
  ```

  Shutdown test using `make test-qemu-stop`

* Or, test using Debian running in a container (faster, your system must
  support docker-in-docker):

  ```shell
  $ make test-debian-start
  $ make test-debian-test
  ```

  Shutdown test using `make test-debian-stop`

Either way, when completed, access Grafana at http://localhost:3000 and
Prometheus at http://localhost:9090

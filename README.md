# Ansible playbook to install Prometheus and Grafana to a Raspberry PI.

Intended for easy (re-)deployment and updating of the monitoring tools onto a
Raspberry Pi.

It will:

1. Install docker on target hosts
2. Create a docker-compose.yml for Prometheus and Grafana (and node_exporter
   as default scraping target for Prometheus with info from the host)
3. Automatically provision a datasource for Prometheus in Grafana
4. Start said Docker compose

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
    scrape_configs:
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

You can set the following ansible variables for this role to alter its results:

* `scrape_configs` Prometheus config where to obtain data (default: config to
  scrape local node_exporter)
* `docker_install` assume docker is already installed (default: false)
* `docker_pull` set to "always" to update container images (default: "policy",
  which won't pull updates)
* `prometheus_grafana_dir` to set where docker-compose.yml is installed.
  (default: $HOME/prometheus_grafana)
* `grafana_anonymous` should access to grafana without login be permitted (
  default: false)
* `grafana_anonymous_edit` should anonymous users be permitted to modify
  dashboards (default: false)
* `grafana_admin_password` to automatically set admin password

## Security

* Grafana and Prometheus containers don't support execution using an arbitrary
  user id. But as the docker socket isn't bind-mounted into these containers,
  they should be isolated from the main system.
* To monitor for image updates, consider installing a monitoring tool
  like https://crazymax.dev/diun/ and when updates are published re-running your
  playbook with `docker_pull: "always"`.

## Testing locally (for development)

This project provides two ways to locally test and run the deployment.
Using qemu to emulate a raspberry or a plain debian:bookworm image.

* To test using qemu executed in a container (currently not working due
  to [an issue](https://github.com/carlosperate/docker-qemu-rpi-os/issues/6)):

  ```shell
  $ make test-qemu-start
  $ make test-qemu-logs
  (CTRL-c when ready)
  $ make qemu-test
  ```

* Or, test using Debian running in a container (faster, your system must
  support docker-in-docker):

  ```shell
  $ make docker-debian-start
  $ make test
  ```

Either way, when completed, access Grafana at http://localhost:3000 and
Prometheus at http://localhost:9090

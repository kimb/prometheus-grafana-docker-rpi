# Ansible playbook to install Prometheus and Grafana to a Raspberry PI.

Intended for easy (re-)deployment of the monitoring tools onto a Raspberry Pi.

It will:

1. Install docker on target hosts
2. Create a docker-compose.yml for Prometheus and Grafana (and node_exporter to
   generate some test data for Prometheus to scrape)
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

* `docker_install` set to false to assume docker is already installed.
* `prometheus_grafana_dir` to set where docker-compose.yml is installed.
  Defaults to $HOME/prometheus_grafana
* `grafana_anonymous` should access to grafana without login be permitted
* `grafana_admin_password` to automatically set admin password

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

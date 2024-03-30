# Ansible playbook to install Prometheus and Grafana to Raspberry PI.

Intended for easy (re-)deployment of the monitoring tools to a headless RPi.

It will:

1. Install docker on target hosts
2. Create a user `pi` (if not already present)
3. Create a docker-compose.yml for Prometheus and Grafana (and node_exporter to
   generate some test data for Prometheus to scrape)
4. Start said Docker compose

After that:

* Grafana is available on port `3000`
  * Login using admin/admin, you will be asked to change the password
  * In Connections/Data sources, select "Add data source", select "Prometheus"
  * Enter "Prometheus Server URL": `http://prometheus:9090`
  * Press "Save & test"
* Prometheus is available on port `9090`

## Usage

You can either check out this repository and use it directly in place

### Usage by modifying a clone

Set hosts to monitor by modifying `roles/prometheus_grafana/defaults/main.yml`
with your scraping needs.

Then create a hosts file targeting your Raspberry Pi. For example
`raspberry-hosts.yml` containing:

```yaml
default:
  hosts:
    my-raspberry.local:
      ansible_user: pi
      ansible_password: raspberry
```

Then run:

```shell
$ ansible-playbook -i raspberry-hosts.yml main.yml
```

### Usage as a role from your own playbook

Create `requirements.yml`:

```yaml
---
roles:
  - name: prometheus_grafana
    src: ssh://git@github.com/kimb/prometheus-grafana-docker-rpi.git
    version: master
    scm: git
```

Install it: `ansible-galaxy install -r requirements.yml`

Then use it in your playbook:

```yaml
- hosts: raspberry-dashboard.local
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
    - prometheus_grafana
```

## Testing locally

This project provides two ways to locally test and run the deployment.
Using qemu to emulate a raspberry or a plain debian:bookworm image.

* To test using qemu executed in a container (slow) (currently not working due
  to [an issue](https://github.com/carlosperate/docker-qemu-rpi-os/issues/6)):

   ```shell
   $ make qemu-raspberry-start
   $ ansible-playbook -i docker-qemu-raspberry-hosts.yml main.yml
   ```

* Or, test using Debian running in a container (much faster, your system must
  support docker-in-docker):

  ```shell
  $ make docker-debian-start
  $ make qemu-raspberry-logs
  (CTRL-c when ready)
  $ ansible-playbook -i docker-debian-hosts.yml main.yml
  ```

Either way, when completed, access Grafana at http://localhost:3000 and
Prometheus at http://localhost:9090

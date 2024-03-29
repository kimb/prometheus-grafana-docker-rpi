# Ansible playbook to install Prometheus and Grafana to Raspberry PI.

Intended for easy (re-)deployment of the monitoring tools to a headless RPi.

It will:

1. Install docker on target hosts
2. Create user `pi`
3. Create a docker-compose.yml for Prometheus and Grafana (and node_exporter to
   generate some test data for Prometheus to scrape)
4. Start said Docker compose

After that:

* Grafana is available at port `3000`
  * Login using admin/admin, you will be asked to change the password
  * In Connections/Data sources, select "Add data source", select "Prometheus"
  * Enter "Prometheus Server URL": `http://prometheus:9090`
  * Press "Save & test"
* Prometheus is available at port `9090`

## Usage

Create a hosts file targeting your Raspberry Pi. For
example `raspberry-hosts.yml` containing:

```yaml
default:
  hosts:
    my-raspberry:
      ansible_user: pi
      ansible_password: raspberry
```

Then run:

```shell
$ ansible-playbook -i raspberry-hosts.yml main.yml
```

## Testing locally

This project provides two ways to locally test and run the deployment.
Using qemu to emulate a raspberry or a plain debian:bookworm image.

### Test using qemu executed in a container

```shell
$ make qemu-raspberry-start
$ ansible-playbook -i docker-qemu-raspberry-hosts.yml main.yml
```

### Test using Debian running in a container

```shell
$ make docker-debian-start
$ ansible-playbook -i docker-debian-hosts.yml main.yml
```

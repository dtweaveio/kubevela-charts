# charts
[![LICENSE](https://img.shields.io/github/license/kubevela/charts.svg?style=flat-square)](/LICENSE)

The chart repo for holding KubeVela's helm charts.

## Usage
```shell
helm repo add kubevela https://charts.dtweave.com/kubevela/
helm repo update kubevela
```

## Install

```shell
helm install --create-namespace -n vela-system kubevela kubevela/vela-core --wait
helm install kubevela kubevela/vela-workflow # install vela-workflow
```
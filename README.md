# Test K8S-Kind setup in github actions

* uses [kind-action](https://github.com/helm/kind-action) to setup a kind cluster named `chart-testing`
* installs ingress controller into the kind cluster
* builds a simple app container image
* uploads the image into the kind cluster
* deploys a simple app using a `deployment`, a `service` and an `ingress` into a `namespace`
* waits for the app to be reachable through the ingress
* calls the app through the ingress
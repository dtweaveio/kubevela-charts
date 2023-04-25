package main

openKruise: {
	type: "helm"
	name: "open-kruise"
	properties: {
		repoType: "helm"
		url:      "https://openkruise.github.io/charts/"
		chart:    "kruise"
		version:  "1.4.0"
		values:
			crds:
  			managed: parameter.crds.managed
			installation:
				namespace: parameter.installation.namespace
				createNamespace: parameter.installation.createNamespace
	}
}

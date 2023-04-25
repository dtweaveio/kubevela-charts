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
			featureGates: parameter.featureGates
			enableKubeCacheMutationDetector: parameter.enableKubeCacheMutationDetector
			manager:
				log:
					level: parameter.manager.log.level
				replicas: parameter.manager.replicas
				image:
					repository: parameter.manager.image.repository
					tag: parameter.manager.image.tag
				webhook:
					port: parameter.manager.webhook.port
				metrics:
					port: parameter.manager.metrics.metrics
				healthProbe:
					port: parameter.manager.healthProbe.port
				pprofAddr: parameter.manager.pprofAddr
				resyncPeriod: parameter.manager.resyncPeriod
				resources:
					limits:
						cpu: parameter.manager.resources.limits.cpu
						memory: parameter.manager.resources.limits.memory
					requests:
						cpu: parameter.manager.resources.limits.cpu
						memory: parameter.manager.resources.limits.memory
				hostNetwork: parameter.manager.hostNetwork
	}
}

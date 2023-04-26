package main

openKruise: {
	type: "helm"
	name: "open-kruise"
	properties: {
		repoType: "helm"
		url:      "https://openkruise.github.io/charts/"
		chart:    "kruise"
		version:  "1.4.0"
		values: {
			crds: {
				managed: parameter.crds.managed
			}
			installation: {
				namespace:       parameter.installation.namespace
				createNamespace: parameter.installation.createNamespace
			}
			if parameter.featureGates != _|_ {
				featureGates: parameter.featureGates
			}
			enableKubeCacheMutationDetector: parameter.enableKubeCacheMutationDetector
			manager: {
				log: {
					level: parameter.manager.log.level
				}
				replicas: parameter.manager.replicas
				image: {
					repository: parameter.manager.image.repository
					tag:        parameter.manager.image.tag
				}
				webhook: {
					port: parameter.manager.webhook.port
				}
				metrics: {
					port: parameter.manager.metrics.port
				}
				healthProbe: {
					port: parameter.manager.healthProbe.port
				}
				pprofAddr:    parameter.manager.pprofAddr
				resyncPeriod: parameter.manager.resyncPeriod
				resources: {
					limits: {
						cpu:    parameter.manager.resources.limits.cpu
						memory: parameter.manager.resources.limits.memory
					}
					requests: {
						cpu:    parameter.manager.resources.limits.cpu
						memory: parameter.manager.resources.limits.memory
					}
				}
				hostNetwork: parameter.manager.hostNetwork

				if parameter.manager.nodeAffinity != _|_ {
					nodeAffinity: parameter.manager.nodeAffinity
				}
				if parameter.manager.nodeSelector != _|_ {
					nodeSelector: parameter.manager.nodeSelector
				}
				if parameter.manager.tolerations != _|_ {
					tolerations: parameter.manager.tolerations
				}
			}
			webhookConfiguration: {
				failurePolicy: {
					pods: parameter.webhookConfiguration.failurePolicy.pods
				}
				timeoutSeconds: parameter.webhookConfiguration.timeoutSeconds
			}
			daemon: {
				log: {
					level: parameter.daemon.log.level
				}
				port:           parameter.daemon.port
				pprofAddr:      parameter.daemon.pprofAddr
				socketLocation: parameter.daemon.socketLocation
				if parameter.daemon.socketFile != _|_ {
					socketFile: parameter.daemon.socketFile
				}
				if parameter.daemon.nodeSelector != _|_ {
					nodeSelector: parameter.daemon.nodeSelector
				}
				if parameter.daemon.extraEnvs != _|_ {
					extraEnvs: parameter.daemon.extraEnvs
				}
				resources: {
					limits: {
						cpu:    parameter.daemon.resources.limits.cpu
						memory: parameter.daemon.resources.limits.memory
					}
					requests: {
						cpu:    parameter.daemon.resources.limits.cpu
						memory: parameter.daemon.resources.limits.memory
					}
				}
			}
			serviceAccount: {
				if parameter.serviceAccount.annotations != _|_ {
					annotations: parameter.serviceAccount.annotations
				}
			}
		}
	}
}

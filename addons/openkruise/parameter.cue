// parameter.cue is used to store addon parameters.
//
// You can use these parameters in template.cue or in resources/ by 'parameter.myparam'
//
// For example, you can use parameters to allow the user to customize
// container images, ports, and etc.
parameter: {
	crds: {
		managed: *true | bool
	}
	// +usage=Custom parameter description
	installation: {
		namespace:       *"kruise-system" | string
		createNamespace: *true | bool
	}
	featureGates:                    *"" | string
	enableKubeCacheMutationDetector: *false | bool
	manager: {
		log: {
			level: *"4" | string
		}
		replicas: *2 | int
		image: {
			repository: *"openkruise/kruise-manager" | string
			tag:        *"v1.4.0" | string
		}
		webhook: {
			port: *9876 | int
		}
		metrics: {
			port: *8080 | int
		}
		healthProbe: {
			port: *8000 | int
		}
		pprofAddr:    *"localhost:8090" | string
		resyncPeriod: *"0" | string
		resources: {
			limits: {
				cpu:    *"500m" | string
				memory: *"1024Mi" | string
			}
			requests: {
				cpu:    *"200m" | string
				memory: *"512Mi" | string
			}
		}
		hostNetwork:  *true | bool
		nodeAffinity: *{} | {...}
		nodeSelector: *{} | {...}
		tolerations:  *[] | [...]
	}
	webhookConfiguration: {
		failurePolicy: {
			pods: *"Ignore" | string
		}
		timeoutSeconds: *30 | int
	}
	serviceAccount: {
		annotations: *{} | {...}
	}
	daemon: {
		log: {
			level: *"4" | string
		}
		port:           *10221 | int
		pprofAddr:      *"localhost:10222" | string
		socketLocation: *"/var/run" | string
		socketFile?:    *"" | string
		resources: {
			limits: {
				cpu:    *"50m" | string
				memory: *"128Mi" | string
			}
			requests: {
				cpu:    *"0" | string
				memory: *"0" | string
			}
		}
	}
}

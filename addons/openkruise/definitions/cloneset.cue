cloneset: {
	type:  "component"
	alias: ""
	annotations: {}
	labels: {}
	description: "CloneSet 控制器提供了高效管理无状态应用的能力，它可以对标原生的 Deployment，但 CloneSet 提供了很多增强功能。"
	attributes: workload: definition: {
		apiVersion: "apps.kruise.io/v1alpha1"
		kind:       "CloneSet"
	}
}

template: {
	output: {}

	parameter: {
		// +usage=Specify the labels in the workload
		labels?: [string]: string

		// +usage=Specify the annotations in the workload
		annotations?: [string]: string

		// +usage=Which image would you like to use for your service
		// +short=i
		image: string

		// +usage=Specify image pull policy for your service
		imagePullPolicy?: "Always" | "Never" | "IfNotPresent"

		// +usage=Specify image pull secrets for your service
		imagePullSecrets?: [...string]

		// +ignore
		// +usage=Deprecated field, please use ports instead
		// +short=p
		port?: int

		// +usage=Which ports do you want customer traffic sent to, defaults to 80
		ports?: [...{
			// +usage=Number of port to expose on the pod's IP address
			port: int
			// +usage=Name of the port
			name?: string
			// +usage=Protocol for port. Must be UDP, TCP, or SCTP
			protocol: *"TCP" | "UDP" | "SCTP"
			// +usage=Specify if the port should be exposed
			expose: *false | bool
			// +usage=exposed node port. Only Valid when exposeType is NodePort
			nodePort?: int
		}]

		// +ignore
		// +usage=Specify what kind of Service you want. options: "ClusterIP", "NodePort", "LoadBalancer"
		exposeType: *"ClusterIP" | "NodePort" | "LoadBalancer"

		// +ignore
		// +usage=If addRevisionLabel is true, the revision label will be added to the underlying pods
		addRevisionLabel: *false | bool

		// +usage=Commands to run in the container
		cmd?: [...string]

		// +usage=Arguments to the entrypoint
		args?: [...string]

		// +usage=Define arguments by using environment variables
		env?: [...{
			// +usage=Environment variable name
			name: string
			// +usage=The value of the environment variable
			value?: string
			// +usage=Specifies a source the value of this var should come from
			valueFrom?: {
				// +usage=Selects a key of a secret in the pod's namespace
				secretKeyRef?: {
					// +usage=The name of the secret in the pod's namespace to select from
					name: string
					// +usage=The key of the secret to select from. Must be a valid secret key
					key: string
				}
				// +usage=Selects a key of a config map in the pod's namespace
				configMapKeyRef?: {
					// +usage=The name of the config map in the pod's namespace to select from
					name: string
					// +usage=The key of the config map to select from. Must be a valid secret key
					key: string
				}
			}
		}]

		// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
		cpu?: string

		// +usage=Specifies the attributes of the memory resource required for the container.
		memory?: string

		volumeMounts?: {
			// +usage=Mount PVC type volume
			pvc?: [...{
				name:      string
				mountPath: string
				subPath?:  string
				// +usage=The name of the PVC
				claimName: string
			}]
			// +usage=Mount ConfigMap type volume
			configMap?: [...{
				name:        string
				mountPath:   string
				subPath?:    string
				defaultMode: *420 | int
				cmName:      string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}]
			// +usage=Mount Secret type volume
			secret?: [...{
				name:        string
				mountPath:   string
				subPath?:    string
				defaultMode: *420 | int
				secretName:  string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}]
			// +usage=Mount EmptyDir type volume
			emptyDir?: [...{
				name:      string
				mountPath: string
				subPath?:  string
				medium:    *"" | "Memory"
			}]
			// +usage=Mount HostPath type volume
			hostPath?: [...{
				name:      string
				mountPath: string
				subPath?:  string
				path:      string
			}]
		}

		// +usage=Deprecated field, use volumeMounts instead.
		volumes?: [...{
			name:      string
			mountPath: string
			// +usage=Specify volume type, options: "pvc","configMap","secret","emptyDir", default to emptyDir
			type: *"emptyDir" | "pvc" | "configMap" | "secret"
			if type == "pvc" {
				claimName: string
			}
			if type == "configMap" {
				defaultMode: *420 | int
				cmName:      string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}
			if type == "secret" {
				defaultMode: *420 | int
				secretName:  string
				items?: [...{
					key:  string
					path: string
					mode: *511 | int
				}]
			}
			if type == "emptyDir" {
				medium: *"" | "Memory"
			}
		}]

		// +usage=Instructions for assessing whether the container is alive.
		livenessProbe?: #HealthProbe

		// +usage=Instructions for assessing whether the container is in a suitable state to serve traffic.
		readinessProbe?: #HealthProbe

		// +usage=Specify the hostAliases to add
		hostAliases?: [...{
			ip: string
			hostnames: [...string]
		}]
	}

	mountsArray: [
		if parameter.volumeMounts != _|_ && parameter.volumeMounts.pvc != _|_ for v in parameter.volumeMounts.pvc {
			{
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
				name: v.name
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.configMap != _|_ for v in parameter.volumeMounts.configMap {
			{
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
				name: v.name
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.secret != _|_ for v in parameter.volumeMounts.secret {
			{
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
				name: v.name
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.emptyDir != _|_ for v in parameter.volumeMounts.emptyDir {
			{
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
				name: v.name
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.hostPath != _|_ for v in parameter.volumeMounts.hostPath {
			{
				mountPath: v.mountPath
				if v.subPath != _|_ {
					subPath: v.subPath
				}
				name: v.name
			}
		},
	]

	volumesList: [
		if parameter.volumeMounts != _|_ && parameter.volumeMounts.pvc != _|_ for v in parameter.volumeMounts.pvc {
			{
				name: v.name
				persistentVolumeClaim: claimName: v.claimName
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.configMap != _|_ for v in parameter.volumeMounts.configMap {
			{
				name: v.name
				configMap: {
					defaultMode: v.defaultMode
					name:        v.cmName
					if v.items != _|_ {
						items: v.items
					}
				}
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.secret != _|_ for v in parameter.volumeMounts.secret {
			{
				name: v.name
				secret: {
					defaultMode: v.defaultMode
					secretName:  v.secretName
					if v.items != _|_ {
						items: v.items
					}
				}
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.emptyDir != _|_ for v in parameter.volumeMounts.emptyDir {
			{
				name: v.name
				emptyDir: medium: v.medium
			}
		},

		if parameter.volumeMounts != _|_ && parameter.volumeMounts.hostPath != _|_ for v in parameter.volumeMounts.hostPath {
			{
				name: v.name
				hostPath: {
					path: v.path
				}
			}
		},
	]

	deDupVolumesArray: [
		for val in [
			for i, vi in volumesList {
				for j, vj in volumesList if j < i && vi.name == vj.name {
					_ignore: true
				}
				vi
			},
		] if val._ignore == _|_ {
			val
		},
	]

	#HealthProbe: {
		// +usage=Instructions for assessing container health by executing a command. Either this attribute or the httpGet attribute or the tcpSocket attribute MUST be specified. This attribute is mutually exclusive with both the httpGet attribute and the tcpSocket attribute.
		exec?: {
			// +usage=A command to be executed inside the container to assess its health. Each space delimited token of the command is a separate array element. Commands exiting 0 are considered to be successful probes, whilst all other exit codes are considered failures.
			command: [...string]
		}

		// +usage=Instructions for assessing container health by executing an HTTP GET request. Either this attribute or the exec attribute or the tcpSocket attribute MUST be specified. This attribute is mutually exclusive with both the exec attribute and the tcpSocket attribute.
		httpGet?: {
			// +usage=The endpoint, relative to the port, to which the HTTP GET request should be directed.
			path: string
			// +usage=The TCP socket within the container to which the HTTP GET request should be directed.
			port:    int
			host?:   string
			scheme?: *"HTTP" | string
			httpHeaders?: [...{
				name:  string
				value: string
			}]
		}

		// +usage=Instructions for assessing container health by probing a TCP socket. Either this attribute or the exec attribute or the httpGet attribute MUST be specified. This attribute is mutually exclusive with both the exec attribute and the httpGet attribute.
		tcpSocket?: {
			// +usage=The TCP socket within the container that should be probed to assess container health.
			port: int
		}

		// +usage=Number of seconds after the container is started before the first probe is initiated.
		initialDelaySeconds: *0 | int

		// +usage=How often, in seconds, to execute the probe.
		periodSeconds: *10 | int

		// +usage=Number of seconds after which the probe times out.
		timeoutSeconds: *1 | int

		// +usage=Minimum consecutive successes for the probe to be considered successful after having failed.
		successThreshold: *1 | int

		// +usage=Number of consecutive failures required to determine the container is not alive (liveness probe) or not ready (readiness probe).
		failureThreshold: *3 | int
	}
}

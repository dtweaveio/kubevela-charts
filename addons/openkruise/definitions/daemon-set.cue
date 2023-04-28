import (
	"strconv"
	"strings"
)

"daemon-set": {
	type:  "component"
	alias: ""
	annotations: {}
	labels: {}
	description: "这个控制器基于原生 DaemonSet 上增强了发布能力，比如 灰度分批、按 Node label 选择、暂停、热升级等。"
	attributes: workload: definition: {
		apiVersion: "apps.kruise.io/v1alpha1"
		kind:       "DaemonSet"
	}
}

template: {
	patch: metadata: annotations: {
		if parameter["predownloadParallelism"] != _|_ {
			"apps.kruise.io/image-predownload-parallelism": parameter.predownloadParallelism
		}
		if parameter["predownloadReady"] != _|_ {
			"apps.kruise.io/image-predownload-min-updated-ready-pods": parameter.predownloadReady
		}
	}
	output: {
		apiVersion: "apps.kruise.io/v1alpha1"
		kind:       "DaemonSet"
		spec: {
			selector: matchLabels: {
				"app.oam.dev/component": context.name
			}
			template: {
				metadata: {
					labels: {
						if parameter.labels != _|_ {
							parameter.labels
						}
						if parameter.addRevisionLabel {
							"app.oam.dev/revision": context.revision
						}
						"app.oam.dev/name":      context.appName
						"app.oam.dev/component": context.name
					}
					if parameter.annotations != _|_ {
						annotations: parameter.annotations
					}
				}
				spec: {
					containers: [{
						name:  context.name
						image: parameter.image

						if parameter["ports"] != _|_ {
							ports: [ for v in parameter.ports {
								{
									containerPort: v.port
									protocol:      v.protocol
									if v.name != _|_ {
										name: v.name
									}
									if v.name == _|_ {
										_name: "port-" + strconv.FormatInt(v.port, 10)
										name:  *_name | string
										if v.protocol != "TCP" {
											name: _name + "-" + strings.ToLower(v.protocol)
										}
									}
								}}]
						}

						if parameter["imagePullPolicy"] != _|_ {
							imagePullPolicy: parameter.imagePullPolicy
						}

						if parameter["cmd"] != _|_ {
							command: parameter.cmd
						}

						if parameter["args"] != _|_ {
							args: parameter.args
						}

						if parameter["env"] != _|_ {
							env: parameter.env
						}

						if context["config"] != _|_ {
							env: context.config
						}

						if parameter["cpu"] != _|_ {
							resources: {
								limits: cpu:   parameter.cpu
								requests: cpu: parameter.cpu
							}
						}

						if parameter["memory"] != _|_ {
							resources: {
								limits: memory:   parameter.memory
								requests: memory: parameter.memory
							}
						}

						if parameter["livenessProbe"] != _|_ {
							livenessProbe: parameter.livenessProbe
						}

						if parameter["readinessProbe"] != _|_ {
							readinessProbe: parameter.readinessProbe
						}
					}]

					if parameter["hostAliases"] != _|_ {
						// +patchKey=ip
						hostAliases: parameter.hostAliases
					}

					if parameter["imagePullSecrets"] != _|_ {
						imagePullSecrets: [ for v in parameter.imagePullSecrets {
							name: v
						},
						]
					}
				}
			}

			if parameter["updateStrategy"] != _|_ {
				updateStrategy: {
					type: "RollingUpdate"
					rollingUpdate: {
						rollingUpdateType: parameter.updateStrategy.rollingUpdateType
						// 最多不可用的 Pod 数量
						if parameter.updateStrategy.maxUnavailable != _|_ {
							maxUnavailable: parameter.updateStrategy.maxUnavailable
						}

						// 标签选择升级
						if parameter.updateStrategy.selectorLabels != _|_ {
							selector: matchLabels: parameter.updateStrategy.selectorLabels
						}

						// 分批灰度升级或扩容
						partition: parameter.updateStrategy.partition

						// 暂停升级
						if parameter.updateStrategy.paused != _|_ {
							paused: parameter.updateStrategy.paused
						}
					}
				}
			}

			if parameter["scaleStrategy"] != _|_ {
				scaleStrategy: {
					// 流式扩容（绝对值或者百分比）
					if parameter.scaleStrategy.maxUnavailable != _|_ {
						maxUnavailable: parameter.scaleStrategy.maxUnavailable
					}
				}
			}

			if parameter["reserveOrdinals"] != _|_ {
				reserveOrdinals: parameter.reserveOrdinals
			}
		}
	}

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

		// +usage=Instructions for assessing whether the container is alive.
		livenessProbe?: #HealthProbe

		// +usage=Instructions for assessing whether the container is in a suitable state to serve traffic.
		readinessProbe?: #HealthProbe

		// +usage=Specify the hostAliases to add
		hostAliases?: [...{
			ip: string
			hostnames: [...string]
		}]

		// +usage=DaemonSet更新与升级策略
		updateStrategy?: {
			// 	就地升级
			// +usage=升级方式
			// Standard: 对于每个 node，控制器会先删除旧的 daemon Pod，再创建一个新 Pod，和原生 DaemonSet 行为一致。
			// Surging: 对于每个 node，控制器会先创建一个新 Pod，等它 ready 之后再删除老 Pod。
			// Standard (默认): 控制器会重建升级 Pod，与原生 DaemonSet 行为一致。你可以通过 maxUnavailable 或 maxSurge 来控制重建新旧 Pod 的顺序。
			// InPlaceIfPossible: 控制器会优先尝试原地升级 Pod，如果不行再采用重建升级。具体参考下方阅读文档。
			rollingUpdateType: *"Standard" | "InPlaceIfPossible" | "Surging" | "Standard"
			// 标签选择升级
			// 这个策略支持用户通过配置 node 标签的 selector，来指定灰度升级某些特定类型 node 上的 Pod。
			selectorLabels?: [string]: string
			// 分批灰度升级或扩容,Partition 的语义是 保留旧版本 Pod 的数量，默认为 0
			partition: *0 | int
			// +usage=MaxUnavailable 限制下属最多不可用的 Pod 数量，防止大规模pod失效
			// 注意，maxUnavailable 只能配合 podManagementPolicy 为 Parallel 来使用。
			// 注意，该特性会导致发布过程中的 order 顺序不能严格保证
			maxUnavailable?: int | string
			// 暂停升级
			paused?: bool
		}
		// 新镜像预热时的并发度
		// 使用之前需要开启feature-gate，CloneSet 控制器会自动在所有旧版本 pod 所在 node 节点上预热你正在灰度发布的新版本镜像
		//predownloadParallelism?: *10 | string | int
		// 控制在少量新版本 Pod 已经升级成功之后再执行镜像预热(取值:绝对值数字或百分比)
		//predownloadReady?: string | int
	}

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

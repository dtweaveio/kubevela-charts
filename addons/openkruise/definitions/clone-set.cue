import (
	"strconv"
	"strings"
)

"clone-set": {
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
	output: {
		apiVersion: "apps.kruise.io/v1alpha1"
		kind:       "CloneSet"
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

						if parameter["pvcTemplates"] != _|_ {
							volumeMounts: [ for v in parameter.pvcTemplates {
								name:      v.name
								mountPath: v.mountPath
							}]
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

			// volumeClaimTemplates
			if parameter["pvcTemplates"] != _|_ {
				volumeClaimTemplates: [ for v in parameter.pvcTemplates {
					metadata: name: v.name
					spec: {
						accessModes: [ "ReadWriteOnce"]
						resources: requests: storage: v.storage
					}
				}]
			}

			if parameter["updateStrategy"] != _|_ {
				updateStrategy: {
					// 升级策略
					if parameter.updateStrategy.podUpdatePolicy != _|_ {
						type: parameter.updateStrategy.podUpdatePolicy
						if parameter.updateStrategy.podUpdatePolicy == "InPlaceIfPossible" && parameter.updateStrategy.gracePeriodSeconds != _|_ {
							inPlaceUpdateStrategy: gracePeriodSeconds: parameter.updateStrategy.gracePeriodSeconds
						}
					}

					// 升级顺序
					if parameter.updateStrategy.weightPriority != _|_ {
						// 按照权重升级
						priorityStrategy: {
							weightPriority: [ for v in parameter.updateStrategy.weightPriority {
								weight: v.weight
								matchSelector: matchLabels: v.labels
							}]
						}
					}
					if parameter.updateStrategy.orderPriority != _|_ {
						// 按照给定顺序升级
						priorityStrategy: {
							orderPriority: [ for v in parameter.updateStrategy.orderPriority {
								orderedKey: v
							}]
						}
					}

					// 打散策略
					if parameter.updateStrategy.scatterStrategy != _|_ {
						scatterStrategy: [ for v in parameter.updateStrategy.scatterStrategy {
							key:   v.key
							value: v.value
						}]
					}

					// 分批灰度升级或者回滚
					if parameter.updateStrategy.partition != _|_ {
						partition: parameter.updateStrategy.partition
					}

					// 暂停升级
					if parameter.updateStrategy.paused != _|_ {
						paused: parameter.updateStrategy.paused
					}

					// 最多不可用的 Pod 数量
					if parameter.updateStrategy.maxUnavailable != _|_ {
						maxUnavailable: parameter.updateStrategy.maxUnavailable
					}

					//  Pod 超卖数量
					if parameter.updateStrategy.maxSurge != _|_ {
						maxSurge: parameter.updateStrategy.maxSurge
					}
				}
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

		// +usage=CloneSet 允许用户配置 PVC 模板 volumeClaimTemplates，用来给每个 Pod 生成独享的 PVC
		pvcTemplates?: [...{
			name:      string
			storage:   =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
			mountPath: string
		}]

		// +usage=CloneSet更新与升级策略
		updateStrategy?: {
			// 	就地升级
			//  +usage=用户指定重建升级还是原地升级，可选参数如下：
			// 	ReCreate: 控制器会删除旧 Pod 和它的 PVC，然后用新版本重新创建出来。
			//	InPlaceIfPossible: 控制器会优先尝试原地升级 Pod，如果不行再采用重建升级。具体参考下方阅读文档。
			//	InPlaceOnly: 控制器只允许采用原地升级。因此，用户只能修改上一条中的限制字段，如果尝试修改其他字段会被 Kruise 拒绝。
			podUpdatePolicy: *"InPlaceIfPossible" | "ReCreate" | "InPlaceOnly"
			// +usage=用户如果配置了 gracePeriodSeconds 这个字段，控制器在原地升级的过程中会先把 Pod status 改为 not-ready，然后等一段时间（gracePeriodSeconds），最后再去修改 Pod spec 中的镜像版本。
			// 这样，就为 endpoints-controller 这些控制器留出了充足的时间来将 Pod 从 endpoints 端点列表中去除。
			gracePeriodSeconds?: int
			// 顺序升级
			// 按照权重升级
			// +usage=按照权重（weight）进行升级，Pod 优先级是由所有 weights 列表中的 term 来计算 match selector 得出
			weightPriority?: [...{
				weight: int
				labels: [string]: string
			}]
			// 按照给定顺序升级
			// +usage=Pod 优先级是由 orderKey 的 value 决定，这里要求对应的 value 的结尾能解析为 int 值。比如 value "5" 的优先级是 5，value "sts-10" 的优先级是 10。
			orderPriority?: [...string]
			// 打散策略
			// +usage=打散策略，这个策略定义了如何将一类 Pod 打散到整个发布过程中。
			// 比如，针对一个 replica=10 的 CloneSet，我们在 3 个 Pod 中添加了 foo=bar 标签、并设置对应的 scatter 策略，那么在发布的时候这 3 个 Pod 会排在第 1、6、10 个发布。
			scatterStrategy?: [...{
				key:   string
				value: string
			}]
			// 分批灰度升级
			// +usage=保留旧版本 Pod 的数量或百分比，默认为 0。
			// 可通partition分批升级或者回滚
			partition?: int | string
			// +usage=用户可以通过设置 paused 为 true 暂停发布，不过控制器还是会做 replicas 数量管理：
			paused?: bool
			// +usage=MaxUnavailable 限制下属最多不可用的 Pod 数量，防止大规模pod失效
			// 它可以设置为一个绝对值或者百分比，如果不填 Kruise 会设置为默认值 20%。
			maxUnavailable?: int | string
			// +usage=控制最多能扩出来超过 replicas 的 Pod 数量，实现超卖功能
			// 它可以设置为一个绝对值或者百分比，如果不填 Kruise 会设置为默认值 0
			maxSurge?: int | string
		}
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

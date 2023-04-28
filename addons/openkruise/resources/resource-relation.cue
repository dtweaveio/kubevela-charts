package main

resourceRelation: {
	name: "resource-relation"
	type: "k8s-objects"
	properties: objects: [{
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {
			name:      "clone-set-relation"
			namespace: "vela-system"
			labels: "rules.oam.dev/resources": "true"
		}
		data: rules: """
			- parentResourceType:
			    group: apps.kruise.io
			    kind: CloneSet
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			- parentResourceType:
			    group: apps.kruise.io
			    kind: StatefulSet
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			- parentResourceType:
			    group: apps.kruise.io
			    kind: DaemonSet
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			- parentResourceType:
			    group: apps.kruise.io
			    kind: BroadcastJob
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			- parentResourceType:
			    group: apps.kruise.io
			    kind: AdvancedCronJob
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			- parentResourceType:
			    group: apps.kruise.io
			    kind: SidecarSet
			  childrenResourceType:
			    - apiVersion: v1
			      kind: Pod
			"""
	}]
}

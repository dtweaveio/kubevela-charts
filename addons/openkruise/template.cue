package main

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	spec: {
		components: [openKruise,resourceRelation]
		policies: [{
			type: "topology"
			name: "deploy-topology"
			properties:
				clusters: ["local"]
		}]
		workflow: steps: [{
			type: "deploy"
			name: "deploy-kruise"
			properties: policies: ["deploy-topology"]
		}]
	}
}
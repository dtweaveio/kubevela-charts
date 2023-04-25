// parameter.cue is used to store addon parameters.
//
// You can use these parameters in template.cue or in resources/ by 'parameter.myparam'
//
// For example, you can use parameters to allow the user to customize
// container images, ports, and etc.
parameter: {
	crds: {
		managed: true | boolean
	}
	// +usage=Custom parameter description
	installation: {
		namespace:       *"kruise-system" | string
		createNamespace: true | boolean
	}
}
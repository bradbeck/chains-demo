_IMAGE: *"ttl.sh/kaniko-chains" | string @tag(image)

apiVersion: "tekton.dev/v1beta1"
kind:       "TaskRun"
metadata: {
	generateName: "kaniko-chains-run-"
}
spec: {
	taskRef: name: "kaniko-chains"
	params: [{
		name:  "IMAGE"
		value: "\(_IMAGE)"
	}]
	workspaces: [{
		name: "source"
		emptyDir: {}
	}]
}

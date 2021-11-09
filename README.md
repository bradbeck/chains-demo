# Tekton Chains Demo

## WIP Demo
```
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl wait --timeout=5m --for=condition=ready pods -l app.kubernetes.io/part-of=tekton-pipelines -n tekton-pipelines

kubectl apply -f https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml
kubectl wait --timeout=5m --for=condition=ready pods -l app=tekton-chains-controller -n tekton-chains

cosign generate-key-pair k8s://tekton-chains/signing-secrets

kubectl patch configmap chains-config -n tekton-chains -p='{"data":{"artifacts.taskrun.format": "tekton-provenance"}}'
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{"artifacts.taskrun.storage": "oci"}}'

kubectl apply -f https://raw.githubusercontent.com/tektoncd/chains/main/examples/kaniko/kaniko.yaml

export NS=$(xxd -l 16 -c 16 -p < /dev/random)
export IMAGE=ttl.sh/${NS}/kaniko-chains

tkn task start --param IMAGE=$IMAGE --use-param-defaults --workspace name=source,emptyDir="" kaniko-chains

tkn tr logs --last -f
```

Check to see if it's signed. It appears this is only true after the signature and attestation have
been successfully pushed to the registry, so may need to keep watching one of the two following commands.
```
tkn tr describe --last -o json | jq -r '.metadata.annotations["chains.tekton.dev/signed"]'
```

The attestation and the signature don't seem to show up in the registry immediately, so may need to keep watching
`crane ls ...` until they do.
```
crane ls ${IMAGE}
```

Verify the signature and the attestation.
```
cosign verify --key cosign.pub ${IMAGE}
cosign verify-attestation --key cosign.pub ${IMAGE}
```

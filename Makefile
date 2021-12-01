KIND_INSTANCE=k8s-dagster-playground

# creates a K8s instance
.PHONY: k8s_new
k8s_new:
	kind create cluster --config ./kind/kind.yaml --name $(KIND_INSTANCE)

# deletes a k8s instance
.PHONY: k8s_drop
k8s_drop:
	kind delete cluster --name $(KIND_INSTANCE)

# sets KUBECONFIG for the K8s instance
.PHONY: k8s_connect
k8s_connect:
	kind export kubeconfig --name $(KIND_INSTANCE)

.PHONY: helm_init
helm_init:
	helm repo add minio https://charts.min.io/

.PHONY: install_infra
install_infra: k8s_connect
	# install minio as we'd like an S3 like backend
	kubectl create namespace minio
	# install minio with 4 replicas and a small amount of memory
	# create a dagster-data bucket to use for storing our data
	helm install --namespace minio --set buckets[0].name=dagster-data,buckets[0].policy=none,buckets[0].purge=false --set replicas=4 --set resources.requests.memory=120m --set rootUser=rootuser,rootPassword=rootpass123 minio minio/minio
	# install dagster
	
	

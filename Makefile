KIND_INSTANCE=k8s-dagster-playground

DAGSTER_VERSION=0.13.11

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
	helm repo add dagster https://dagster-io.github.io/helm

.PHONY: install_infra
install_infra: k8s_connect
	# install minio as we'd like an S3 like backend
	# configure with 4 replicas and a small amount of memory
	# create a dagster-data bucket to use for storing our data
	helm install --namespace minio --create-namespace --set buckets[0].name=dagster-data,buckets[0].policy=none,buckets[0].purge=false --set replicas=4 --set resources.requests.memory=120m --set rootUser=rootuser,rootPassword=rootpass123 minio minio/minio
	# install dagster
	# uses a values.yaml as the configuration is complicated ;-(
	helm install --namespace dagster --create-namespace --values ./helm/dagster/values.yaml --version $(DAGSTER_VERSION) dagster dagster/dagster
	# add in the S3 secrets so that dagster run instances can get to S3
	kubectl create secret generic -n=dagster dagster-aws-access-key-id --from-literal=AWS_ACCESS_KEY_ID=rootuser
	kubectl create secret generic -n=dagster dagster-aws-secret-access-key --from-literal=AWS_SECRET_ACCESS_KEY=rootpass123

# loads the docker containers into the kind environments
.PHONY: k8s_side_load
k8s_side_load:
	kind load docker-image project-example --name $(KIND_INSTANCE)

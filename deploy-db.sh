# /bin/bash

# transformar o docker-compose para o formato kubernates
eval docker build -t kompose https://github.com/kubernetes/kompose.git\#main && \
     docker run --rm -it -v .:/opt kompose sh -c "cd /opt && kompose convert -f docker-compose-prd.yml"

# comandos para realizar deploy
eval kubectl apply -f ./mongodb-compass-deployment.yaml
eval kubectl apply -f ./mongodb-compass-tcp-service.yaml
eval kubectl apply -f ./mongo-deployment.yaml
eval kubectl apply -f ./mongo-tcp-service.yaml

# remove os manifests
eval sudo rm -f ./mongo-deployment.yaml
eval sudo rm -f ./mongo-tcp-service.yaml
eval sudo rm -f ./mongodb-compass-deployment.yaml
eval sudo rm -f ./mongodb-compass-tcp-service.yaml
eval sudo rm -f ./streamlit-deployment.yaml
eval sudo rm -f ./streamlit-tcp-service.yaml

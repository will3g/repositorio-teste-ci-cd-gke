#!/bin/bash

DOCKER_USERNAME=$1
INSTANCE_IMAGE=$2
GKE_INSTANCE_NAME=$3
GKE_INSTANCE_PORT=$4
GKE_FILE_NAME=$5

cat <<EOF > $GKE_FILE_NAME
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    kompose.cmd: kompose convert -f docker-compose-prd.yml
    kompose.service.type: LoadBalancer
    kompose.version: 1.34.0 (cbf2835db)
  labels:
    io.kompose.service: $GKE_INSTANCE_NAME
  name: $GKE_INSTANCE_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      io.kompose.service: $GKE_INSTANCE_NAME
  strategy:
    type: Recreate
  template:
    metadata:
      annotations:
        kompose.cmd: kompose convert -f docker-compose-prd.yml
        kompose.service.type: LoadBalancer
        kompose.version: 1.34.0 (cbf2835db)
      labels:
        io.kompose.service: $GKE_INSTANCE_NAME
    spec:
      containers:
        - env:
            - name: MONGO_HOST
              value: mongo-tcp
            - name: MONGO_PASSWORD
              value: root
            - name: MONGO_PORT
              value: "27017"
            - name: MONGO_USER
              value: root
          image: $DOCKER_USERNAME/$INSTANCE_IMAGE:latest
          livenessProbe:
            exec:
              command:
                - curl -f http://$GKE_INSTANCE_NAME-tcp:$GKE_INSTANCE_PORT/ || exit 1
            failureThreshold: 3
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 10
          name: $GKE_INSTANCE_NAME
          ports:
            - containerPort: $GKE_INSTANCE_PORT
              protocol: TCP
          resources:
            limits:
              cpu: 250m
              memory: "536870912"
            requests:
              cpu: 100m
              memory: "268435456"
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    kompose.cmd: kompose convert -f docker-compose-prd.yml
    kompose.service.type: LoadBalancer
    kompose.version: 1.34.0 (cbf2835db)
  labels:
    io.kompose.service: $GKE_INSTANCE_NAME-tcp
  name: $GKE_INSTANCE_NAME-tcp
spec:
  ports:
    - name: "$GKE_INSTANCE_PORT"
      port: $GKE_INSTANCE_PORT
      targetPort: $GKE_INSTANCE_PORT
  selector:
    io.kompose.service: $GKE_INSTANCE_NAME
  type: LoadBalancer
EOF

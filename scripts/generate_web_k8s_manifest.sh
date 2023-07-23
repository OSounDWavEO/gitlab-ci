#!/bin/bash

cat <<EOT >> sts-${CI_PROJECT_NAME}.yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  generation: 1
  labels:
    app: ${CI_PROJECT_NAME}-web
  name: ${CI_PROJECT_NAME}-web
  namespace: ${CI_PROJECT_NAME}
spec:
  podManagementPolicy: OrderedReady
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: ${CI_PROJECT_NAME}-web
  serviceName: ${CI_PROJECT_NAME}-web
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: ${CI_PROJECT_NAME}-web
    spec:
      containers:
      - env:
        - name: NODE_ID
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: INSTANCE_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        image: ${FULL_IMAGE}
        imagePullPolicy: Always
        name: ${CI_PROJECT_NAME}-web
        ports:
        - containerPort: 80
          name: http
        resources:
          limits:
            cpu: "0"
            memory: "0"
          requests:
            cpu: "0"
            memory: "0"
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
  updateStrategy:
    rollingUpdate:
      partition: 0
    type: RollingUpdate
EOT

cat <<EOT >> svc-${CI_PROJECT_NAME}.yml
apiVersion: v1
kind: Service
metadata:
  name: ${CI_PROJECT_NAME}-web-service
  namespace: ${CI_PROJECT_NAME}
spec:
  selector:
    app: ${CI_PROJECT_NAME}-web
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: http
    nodePort: ${EXPOSE_PORT}
EOT

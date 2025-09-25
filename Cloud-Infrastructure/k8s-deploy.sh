# Deployment (NGINX)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels: { app: ${APP_NAME}, version: v1 }
spec:
  replicas: 3
  strategy: { type: RollingUpdate, rollingUpdate: { maxSurge: 1, maxUnavailable: 0 } }
  selector: { matchLabels: { app: ${APP_NAME} } }
  template:
    metadata:
      labels: { app: ${APP_NAME}, version: v1 }
    spec:
      containers:
      - name: nginx
        image: nginx:${IMAGE_TAG}
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        resources:
          requests: { cpu: "100m", memory: "128Mi" }
          limits:   { cpu: "500m", memory: "512Mi" }
        livenessProbe:
          httpGet: { path: /, port: 80 }
          initialDelaySeconds: 20
          periodSeconds: 10
        readinessProbe:
          httpGet: { path: /, port: 80 }
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: config
        configMap: { name: ${APP_NAME}-config }
---
# Service
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}-service
  namespace: ${NAMESPACE}
  labels: { app: ${APP_NAME} }
spec:
  type: ClusterIP
  selector: { app: ${APP_NAME} }
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
---
# Ingress (leave TLS if you have cert-manager + ClusterIssuer)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP_NAME}-ingress
  namespace: ${NAMESPACE}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: ${APP_NAME}.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${APP_NAME}-service
            port: { number: 80 }

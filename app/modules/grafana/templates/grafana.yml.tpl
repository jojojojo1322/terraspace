---
rbac:
  create: true
  pspEnabled: true
  pspUseAppArmor: true
  namespaced: false
  extraRoleRules: []
  extraClusterRoleRules: []

serviceAccount:
  create: true
  name: ${grafana_k8s_sa_name}
  nameTest:
  annotations:
    eks.amazonaws.com/role-arn: ${grafana_iam_role_arn}

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 60
  - type: Resource
    resource:
      name: memory
      targetAverageUtilization: 60

persistence:
  enabled: false

persistence:
  enabled: false
  inMemory:
    enabled: true
    sizeLimit: 300Mi

adminUser: admin

plugins:
  - grafana-piechart-panel
  - grafana-kubernetes-app

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://${prom_svc}
        access: proxy
        isDefault: true
        basicAuth: false
        withCredentials: false
        editable: true
      - name: Loki
        type: loki
        url: http://${loki_svc}
        isDefault: false
        basicAuth: false
        withCredentials: false
        editable: true
      - name: CloudWatch
        type: cloudwatch
        access: proxy
        uid: cloudwatch
        editable: false
        jsonData:
          authType: default
          defaultRegion: ${aws_region}

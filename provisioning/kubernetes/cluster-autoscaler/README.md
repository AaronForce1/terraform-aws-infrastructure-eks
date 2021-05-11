# AUTOSCALING

## AWS EC2 Autoscaling
Currently, although the cluster autoscaler is created along with a proper autoscaler policy, it is not attached properly to the EC2 policy used for EKS' managed node groups.

1. Attach the created EC2 Autoscaling policy to the EC2 role used by the requisite kubernetes cluster.
> The name of the policy should resemble `eks-{app_namespace}-{tfenv}-cluster-autoscaler-policy` which should be attached to the EC2 role resembling `eks-{app_namespace}-{tfenv}{random-numerical-sequence}`

##  Horizontal and Vertical Pod Scaling
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

### Kubernetes Metrics Server Installation
https://github.com/kubernetes-sigs/metrics-server#deployment

The kubernetes cluster needs to have a metrics server in place to expose resource information to respond to needs to scale.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Examples of Autoscaling with multiple metrics
```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: packets-per-second
      target:
        type: AverageValue
        averageValue: 1k
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: main-route
      target:
        type: Value
        value: 10k
status:
  observedGeneration: 1
  lastScaleTime: <some-time>
  currentReplicas: 1
  desiredReplicas: 1
  currentMetrics:
  - type: Resource
    resource:
      name: cpu
    current:
      averageUtilization: 0
      averageValue: 0
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: networking.k8s.io/v1beta1
        kind: Ingress
        name: main-route
      current:
        value: 10k
```
# Karpenter 수행

## 테라폼으로 실행하기

1. 변수설정
  > export AWS_DEFAULT_REGION="ap-northeast-2"
2. 프로바이더 설정

  ```terraform
  terraform {
    required_version = "~> 1.0"

    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
      }
      helm = {
        source  = "hashicorp/helm"
        version = "~> 2.5.1"
      }
      kubectl = {
        source  = "gavinbunney/kubectl"
        version = "~> 1.14"
      }
    }
  }

  provider "aws" {
    region = "ap-northeast-2"
  }

  locals {
    cluster_name = <<Your EKS Cluster Name>>
    partition = data.aws_partition.current.partition
  }

  data "aws_partition" "current" {}
  ```

3. EKS 클러스터 수정
  * Private Subnet Tag 값 추가
    > "karpenter.sh/discovery" = local.cluster_name
  * NodeGroup Security Group Tag 값 추가
    > "karpenter.sh/discovery" = local.cluster_name
  * NodeGroup Node 최소/최대/초기개수 모두 1로 셋팅

4. EC2 Spot 서비스 연결

  ```aws
  aws iam create-role --role-name AmazonEC2SpotFleetTaggingRole \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "spotfleet.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }'

  aws iam attach-role-policy \
    --policy-arn \
      arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole \
    --role-name \
      AmazonEC2SpotFleetTaggingRole

  aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
  aws iam create-service-linked-role --aws-service-name spotfleet.amazonaws.com
  ```

5. Terraform Helm으로 Karpenter 설치
6. Provisioner 설치

  ```yaml
  cat <<EOF > provisioner.yaml
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
    limits:
      resources:
        cpu: 1000
    provider:
      subnetSelector:
        karpenter.sh/discovery: ${local.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery: ${local.cluster_name}
      tags:
        karpenter.sh/discovery: ${local.cluster_name}
    ttlSecondsAfterEmpty: 30
  EOF
  ```

  > kubectl describe provisioner default

7. Karpenter 테스트 (Node Provisioning)

  ```yaml
  cat <<EOF | kubectl apply -f -
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: inflate
  spec:
    replicas: 0
    selector:
      matchLabels:
        app: inflate
    template:
      metadata:
        labels:
          app: inflate
      spec:
        terminationGracePeriodSeconds: 0
        containers:
          - name: inflate
            image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
            resources:
              requests:
                cpu: 1
  EOF
  kubectl scale deployment inflate --replicas 5
  kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller

  # 자동 노드 종료
  kubectl delete deployment inflate
  kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
  ```

For more information, see the [Karpenter User Guide](https://karpenter.sh/v0.13.2/getting-started/).
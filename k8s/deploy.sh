#!/bin/bash

# X-Tok Backend K8s 部署脚本

echo "开始部署 X-Tok Backend 到 Kubernetes..."

# 1. 创建命名空间（可选）
kubectl create namespace xtok --dry-run=client -o yaml | kubectl apply -f -

# 2. 应用存储配置
echo "部署存储配置..."
kubectl apply -f pvc.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f redis-pvc.yaml

# 3. 应用配置
echo "部署配置..."
kubectl apply -f configmap.yaml
kubectl apply -f mysql-init-configmap.yaml

# 4. 应用密钥（注意：需要先更新secret.yaml中的实际值）
echo "部署密钥..."
kubectl apply -f secret.yaml

# 5. 部署数据库服务
echo "部署MySQL..."
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# 6. 部署Redis服务
echo "部署Redis..."
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml

# 7. 部署应用
echo "部署应用..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 8. 部署Ingress（可选，需要配置域名和TLS证书）
echo "部署Ingress..."
kubectl apply -f ingress.yaml

echo "部署完成！"
echo ""
echo "检查部署状态："
echo "kubectl get pods"
echo "kubectl get services"
echo "kubectl get ingress"
echo ""
echo "查看应用日志："
echo "kubectl logs -l app=xtok-backend" 
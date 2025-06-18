# X-Tok Backend Kubernetes 部署指南

## 概述

本项目包含完整的 Kubernetes 部署配置，用于在 K8s 集群中运行 X-Tok Backend 应用。

## 架构组件

- **X-Tok Backend**: 主应用服务 (端口: 22001)
- **MySQL**: 数据库服务 (端口: 3306)
- **Redis**: 缓存服务 (端口: 6379)
- **Ingress**: 外部访问入口

## 部署前准备

### 1. 构建 Docker 镜像

```bash
# 在项目根目录执行
docker build -t xtok-backend:latest .
```

### 2. 推送镜像到镜像仓库（可选）

```bash
# 如果使用私有镜像仓库
docker tag xtok-backend:latest your-registry.com/xtok-backend:latest
docker push your-registry.com/xtok-backend:latest
```

### 3. 更新 Secret 配置

编辑 `secret.yaml` 文件，将以下值替换为实际的 base64 编码值：

```bash
# 生成 base64 编码
echo -n "your-db-password" | base64
echo -n "your-redis-password" | base64
echo -n "your-jwt-secret" | base64
```

### 4. 配置域名和 TLS 证书

编辑 `ingress.yaml` 文件：
- 将 `api.yourdomain.com` 替换为实际域名
- 创建包含 TLS 证书的 Secret

```bash
# 创建 TLS Secret
kubectl create secret tls xtok-tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key
```

## 部署步骤

### 方法一：使用部署脚本

```bash
cd k8s
./deploy.sh
```

### 方法二：手动部署

```bash
# 1. 创建命名空间
kubectl create namespace xtok

# 2. 部署存储
kubectl apply -f pvc.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f redis-pvc.yaml

# 3. 部署配置
kubectl apply -f configmap.yaml
kubectl apply -f mysql-init-configmap.yaml

# 4. 部署密钥
kubectl apply -f secret.yaml

# 5. 部署数据库服务
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# 6. 部署Redis服务
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml

# 7. 部署应用
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 8. 部署Ingress
kubectl apply -f ingress.yaml
```

## 验证部署

### 检查 Pod 状态

```bash
kubectl get pods -n xtok
```

### 检查服务状态

```bash
kubectl get services -n xtok
```

### 检查 Ingress 状态

```bash
kubectl get ingress -n xtok
```

### 查看应用日志

```bash
kubectl logs -l app=xtok-backend -n xtok
```

## 配置说明

### 环境变量

应用通过以下方式获取配置：
- **ConfigMap**: 应用配置、数据库连接等
- **Secret**: 敏感信息（密码、密钥等）
- **环境变量**: 时区设置

### 存储配置

- **应用存储**: 10Gi PVC，用于文件上传
- **MySQL 存储**: 10Gi PVC，用于数据库数据
- **Redis 存储**: 5Gi PVC，用于缓存数据

### 资源限制

- **应用**: 256Mi-512Mi 内存，200m-500m CPU
- **MySQL**: 512Mi-1Gi 内存，250m-500m CPU
- **Redis**: 256Mi-512Mi 内存，100m-200m CPU

## 故障排除

### 常见问题

1. **Pod 启动失败**
   - 检查镜像是否存在
   - 检查 Secret 配置是否正确
   - 查看 Pod 日志

2. **数据库连接失败**
   - 确认 MySQL Pod 已启动
   - 检查数据库密码配置
   - 验证网络连接

3. **Redis 连接失败**
   - 确认 Redis Pod 已启动
   - 检查 Redis 密码配置
   - 验证网络连接

### 调试命令

```bash
# 进入 Pod 调试
kubectl exec -it <pod-name> -n xtok -- /bin/sh

# 查看详细事件
kubectl describe pod <pod-name> -n xtok

# 查看服务端点
kubectl get endpoints -n xtok
```

## 扩展配置

### 水平扩展

```bash
# 扩展应用副本数
kubectl scale deployment xtok-backend --replicas=3 -n xtok
```

### 更新应用

```bash
# 更新镜像
kubectl set image deployment/xtok-backend xtok-backend=xtok-backend:new-version -n xtok
```

## 清理资源

```bash
# 删除所有资源
kubectl delete namespace xtok
``` 



kubectl apply -f k8s/deployment.yaml && kubectl rollout restart deployment xtok-backend && kubectl delete pod -l app=xtok-backend
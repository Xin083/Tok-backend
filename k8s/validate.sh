#!/bin/bash

# X-Tok Backend K8s 配置验证脚本

echo "=== X-Tok Backend K8s 配置验证 ==="
echo ""

# 检查必要的文件是否存在
echo "1. 检查配置文件..."
files=(
    "deployment.yaml"
    "service.yaml"
    "ingress.yaml"
    "configmap.yaml"
    "secret.yaml"
    "pvc.yaml"
    "mysql-deployment.yaml"
    "mysql-service.yaml"
    "mysql-pvc.yaml"
    "redis-deployment.yaml"
    "redis-service.yaml"
    "redis-pvc.yaml"
    "mysql-init-configmap.yaml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file 存在"
    else
        echo "✗ $file 缺失"
    fi
done

echo ""

# 检查 Dockerfile
echo "2. 检查 Dockerfile..."
if [ -f "../Dockerfile" ]; then
    echo "✓ Dockerfile 存在"
    
    # 检查端口配置
    if grep -q "EXPOSE 22001" "../Dockerfile"; then
        echo "✓ Dockerfile 端口配置正确 (22001)"
    else
        echo "✗ Dockerfile 端口配置错误"
    fi
    
    # 检查构建路径
    if grep -q "cmd/web/main.go" "../Dockerfile"; then
        echo "✓ Dockerfile 构建路径正确"
    else
        echo "✗ Dockerfile 构建路径错误"
    fi
else
    echo "✗ Dockerfile 缺失"
fi

echo ""

# 检查端口配置一致性
echo "3. 检查端口配置一致性..."
deployment_port=$(grep "containerPort:" deployment.yaml | sed 's/.*containerPort: //')
service_port=$(grep "targetPort:" service.yaml | sed 's/.*targetPort: //')

if [ "$deployment_port" = "22001" ] && [ "$service_port" = "22001" ]; then
    echo "✓ 端口配置一致 (22001)"
else
    echo "✗ 端口配置不一致"
    echo "  Deployment: $deployment_port"
    echo "  Service: $service_port"
fi

echo ""

# 检查 Secret 配置
echo "4. 检查 Secret 配置..."
if grep -q "cGFzc3dvcmQ=" secret.yaml; then
    echo "⚠ Secret 仍使用默认值，需要更新为实际值"
else
    echo "✓ Secret 已配置"
fi

echo ""

# 检查 Ingress 配置
echo "5. 检查 Ingress 配置..."
if grep -q "api.yourdomain.com" ingress.yaml; then
    echo "⚠ Ingress 仍使用示例域名，需要更新为实际域名"
else
    echo "✓ Ingress 域名已配置"
fi

echo ""

# 检查资源限制
echo "6. 检查资源限制配置..."
if grep -q "resources:" deployment.yaml; then
    echo "✓ 应用资源限制已配置"
else
    echo "✗ 应用资源限制未配置"
fi

if grep -q "resources:" mysql-deployment.yaml; then
    echo "✓ MySQL 资源限制已配置"
else
    echo "✗ MySQL 资源限制未配置"
fi

if grep -q "resources:" redis-deployment.yaml; then
    echo "✓ Redis 资源限制已配置"
else
    echo "✗ Redis 资源限制未配置"
fi

echo ""

# 检查健康检查
echo "7. 检查健康检查配置..."
if grep -q "livenessProbe:" deployment.yaml && grep -q "readinessProbe:" deployment.yaml; then
    echo "✓ 健康检查已配置"
else
    echo "✗ 健康检查未配置"
fi

echo ""

echo "=== 验证完成 ==="
echo ""
echo "注意事项："
echo "1. 确保已构建 Docker 镜像: docker build -t xtok-backend:latest ."
echo "2. 更新 secret.yaml 中的实际密码值"
echo "3. 更新 ingress.yaml 中的实际域名"
echo "4. 确保 K8s 集群已安装 Ingress Controller"
echo "5. 确保存储类 'standard' 可用" 
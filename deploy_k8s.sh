#!/bin/bash

set -e

# 1. 备份本地 gorm_v2.yml
cp config/gorm_v2.yml config/gorm_v2.yml.bak

# 2. 替换所有 Host 字段为 mysql-service
sed -i '' 's/Host: .*/Host: mysql-service/g' config/gorm_v2.yml
# 3. 替换所有 User 字段为 xtok
sed -i '' 's/User: .*/User: xtok/g' config/gorm_v2.yml
# 4. 替换所有 Pass 字段为 12345678
sed -i '' 's/Pass: .*/Pass: 12345678/g' config/gorm_v2.yml
# 5. 替换所有 DataBase 字段为 "xtok"（兼容带引号格式）
sed -i '' 's/DataBase: ".*"/DataBase: "xtok"/g' config/gorm_v2.yml

# 6. 生成并应用 ConfigMap
kubectl create configmap xtok-config --from-file=config/ --dry-run=client -o yaml > k8s/configmap.yaml
kubectl apply -f k8s/configmap.yaml

# 7. 重启 deployment
kubectl rollout restart deployment xtok-backend

# 8. 恢复本地 gorm_v2.yml
mv config/gorm_v2.yml.bak config/gorm_v2.yml

echo "K8s 配置已自动切换为 xtok 用户和数据库并恢复本地开发配置！" 
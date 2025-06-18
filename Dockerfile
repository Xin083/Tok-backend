# 使用官方 Go 镜像作为构建环境
FROM golang:1.23-alpine AS builder

# 设置 Go 代理（使用国内镜像）
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=sum.golang.google.cn

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/web/main.go

# 使用轻量级的 alpine 作为运行环境
FROM alpine:latest

# 安装必要的系统依赖
RUN apk --no-cache add ca-certificates tzdata

# 设置时区
ENV TZ=Asia/Shanghai

# 设置工作目录
WORKDIR /app

# 从构建阶段复制编译好的应用
COPY --from=builder /app/main .
COPY --from=builder /app/config ./config
COPY --from=builder /app/public ./public
COPY --from=builder /app/storage ./storage

# 创建必要的目录
RUN mkdir -p /app/storage/app/public/images \
    && mkdir -p /app/storage/app/public/videos

# 暴露端口
EXPOSE 22001

# 运行应用
CMD ["./main"] 
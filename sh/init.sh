# 定義變量
PORTAINER_COMPOSE_PATH="/workspace/tomwu-gitpod-basic-environment/portainer/docker-compose.yaml"

# 建立 docker network
docker network create web

# 啟動 Docker Compose
docker-compose -f "$PORTAINER_COMPOSE_PATH" up -d

# 等待一段時間讓伺服器啟動完成
echo "Wait 15 seconds..."
sleep 15
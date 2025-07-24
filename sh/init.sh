#!/bin/bash
echo "✅ init.sh triggered" >> /workspace/init.log


# 定義變量
PORTAINER_COMPOSE_PATH="/workspace/tomwu-gitpod-basic-environment/portainer/docker-compose.yaml"

# 建立 docker network
docker network create web

# 啟動 Docker Compose
docker-compose -f "$PORTAINER_COMPOSE_PATH" up -d

# 等待一段時間讓伺服器啟動完成
echo "Wait 15 seconds..."
sleep 15

# 啟動supertoken docker compose
# 定義 Portainer API 信息
PORTAINER_URL="http://localhost:9000"
USERNAME="admin"
PASSWORD="P@ssw0rdAC903220"
STACK_ID="1"
ENDPOINT_ID="2"

# 獲取 API Token
TOKEN=$(curl -s -X POST "$PORTAINER_URL/api/auth" \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" | jq -r '.jwt')

# 檢查是否成功獲取到 token
if [ -z "$TOKEN" ]; then
    echo "Failed to retrieve JWT token"
    exit 1
fi

echo "Successfully retrieved JWT token"

# 停止 Docker 堆疊
curl -s -X POST "$PORTAINER_URL/api/stacks/$STACK_ID/stop?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN"

# 啟動 Docker 堆疊，並添加 endpointId 參數
START_RESPONSE=$(curl -s -X POST "$PORTAINER_URL/api/stacks/$STACK_ID/start?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN")

# 檢查是否成功啟動堆疊
if [ "$START_RESPONSE" == "null" ]; then
    echo "Docker stack started successfully"
else
    echo "Failed to start Docker stack: $START_RESPONSE"
fi
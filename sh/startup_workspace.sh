#!/bin/bash

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
PASSWORD="1qaz2wsx3edc"
FILE_BROWSER_ID="1"
NGINX_ID="2"
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

echo "Token: $TOKEN"
echo

# 列出所有 Endpoints
echo "Endpoints:"
curl -s -X GET "$PORTAINER_URL/api/endpoints" \
  -H "Authorization: Bearer $TOKEN" | jq '.[] | {id: .Id, name: .Name}'
echo

# 列出所有 Stacks
echo "Stacks:"
curl -s -X GET "$PORTAINER_URL/api/stacks" \
  -H "Authorization: Bearer $TOKEN" | jq '.[] | {id: .Id, name: .Name, endpointId: .EndpointId}'

# 停止 Docker 堆疊
echo "Stop Docker Stack"
curl -s -X POST "$PORTAINER_URL/api/stacks/$FILE_BROWSER_ID/stop?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN"
curl -s -X POST "$PORTAINER_URL/api/stacks/$NGINX_ID/stop?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN"

echo "Wait 15 seconds..."
#sleep 15

# 啟動 Docker 堆疊，並添加 endpointId 參數
echo "Start Docker Stack"
FILE_BROWSER_START_RESPONSE=$(curl -s -X POST "$PORTAINER_URL/api/stacks/$FILE_BROWSER_ID/start?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN")
NGINX_START_RESPONSE=$(curl -s -X POST "$PORTAINER_URL/api/stacks/$NGINX_ID/start?endpointId=$ENDPOINT_ID" \
    -H "Authorization: Bearer $TOKEN")

# 檢查是否成功啟動堆疊
if [ "$FILE_BROWSER_START_RESPONSE" == "null" ]; then
    echo "FILE_BROWSER Docker stack started successfully"
else
    echo "Failed to start FILE_BROWSER Docker stack: $FILE_BROWSER_START_RESPONSE"
fi

if [ "$NGINX_START_RESPONSE" == "null" ]; then
    echo "NGINX Docker stack started successfully"
else
    echo "Failed to start NGINX Docker stack: $NGINX_START_RESPONSE"
fi
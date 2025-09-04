#!/bin/bash
while ! docker info > /dev/null 2>&1; do
    sleep 2
done
/usr/local/bin/docker-compose -f /Users/jiehoonk/DevHub/sideprojects/agent-tools/graphiti/mcp_server/docker-compose-sse.yml up -d

#!/bin/bash
echo "Stopping stack..."
docker-compose down

echo "Clearing Grafana provisioning cache (optional - uncomment if needed):"
# docker volume rm monitoring_grafana_data 2>/dev/null || true

echo "Starting stack..."
docker-compose up -d

echo "Waiting for services..."
sleep 5

echo "Checking InfluxDB health..."
docker exec influxdb wget -q -O- http://localhost:8086/ping && echo "✓ InfluxDB is ready" || echo "✗ InfluxDB not ready yet"

echo "Checking Grafana logs..."
docker-compose logs grafana | tail -20

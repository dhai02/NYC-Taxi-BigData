#!/bin/bash
# ============================================================
# FILE: upload_data.sh
# MỤC ĐÍCH: Tải dataset NYC Taxi và upload lên HDFS
# ============================================================

set -e

DATA_DIR=~/nyc_taxi_data
PARQUET_FILE=yellow_tripdata_2026-01.parquet
DOWNLOAD_URL='https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2026-01.parquet'

mkdir -p $DATA_DIR

if [ ! -f "$DATA_DIR/$PARQUET_FILE" ]; then
    echo "[1/3] Đang tải $PARQUET_FILE (~500MB)..."
    wget -O "$DATA_DIR/$PARQUET_FILE" "$DOWNLOAD_URL"
else
    echo "[1/3] File đã tồn tại: $DATA_DIR/$PARQUET_FILE"
fi

echo '[2/3] Tạo cấu trúc thư mục HDFS...'
hdfs dfs -mkdir -p /data/raw
hdfs dfs -mkdir -p /data/processed/cleaned
hdfs dfs -mkdir -p /data/processed/aggregated_by_time
hdfs dfs -mkdir -p /data/processed/aggregated_by_vendor
hdfs dfs -mkdir -p /logs/processing_logs

echo '[3/3] Upload file lên HDFS...'
hdfs dfs -put -f "$DATA_DIR/$PARQUET_FILE" /data/raw/

echo ''
hdfs dfs -ls /data/raw/
hdfs dfs -du -h /data/raw/$PARQUET_FILE
echo '✅ Sẵn sàng chạy pipeline!'

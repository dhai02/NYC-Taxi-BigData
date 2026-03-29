#!/bin/bash
# ============================================================
# FILE: run_pipeline.sh
# MỤC ĐÍCH: Chạy toàn bộ pipeline một lần
# ============================================================

set -e

echo '=================================================='
echo '  NYC TAXI BIG DATA PIPELINE - 01/2026'
echo '=================================================='

source ~/bigdata-env/bin/activate

echo '[STEP 1/3] Chạy EDA...'
python3 src/01_eda.py

echo '[STEP 2/3] Làm sạch dữ liệu...'
python3 src/02_data_cleaning.py

echo '[STEP 3/3] Tổng hợp dữ liệu...'
python3 src/03_aggregation_time.py
python3 src/04_aggregation_vendor.py

echo ''
echo '✅ Pipeline hoàn tất!'
hdfs dfs -ls -R /data/processed/
hdfs dfs -du -h /data/processed/

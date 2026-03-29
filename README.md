# NYC Taxi Big Data Pipeline – Nhóm 4

Dataset: NYC Yellow Taxi Trip Records – Tháng 01/2026  
Stack: Apache Hadoop 3.3.6 + Apache Spark 3.5.1 + Python 3.10+

## Cấu trúc project

```
nyc-taxi-bigdata/
├── requirements.txt
├── setup_env.sh          # Cài đặt toàn bộ môi trường A-Z
├── upload_data.sh        # Tải & upload data lên HDFS
├── run_pipeline.sh       # Chạy toàn bộ pipeline
├── src/
│   ├── 01_eda.py
│   ├── 02_data_cleaning.py
│   ├── 03_aggregation_time.py
│   ├── 04_aggregation_vendor.py
│   └── 05_verify_results.py
└── tests/
    ├── test_cleaning.py
    └── test_aggregation.py
```

## Hướng dẫn nhanh (Ubuntu/WSL2)

```bash
# 1. Cài đặt môi trường
bash setup_env.sh
source ~/.bashrc

# 2. Tải & upload data
bash upload_data.sh

# 3. Chạy pipeline
bash run_pipeline.sh

# Hoặc từng bước
source ~/bigdata-env/bin/activate
python3 src/01_eda.py
python3 src/02_data_cleaning.py
python3 src/03_aggregation_time.py
python3 src/04_aggregation_vendor.py
python3 src/05_verify_results.py

# Chạy tests
pytest tests/ -v
```

## Cấu trúc HDFS

```
/data/raw/                                         ← file parquet gốc
/data/processed/cleaned/                           ← sau làm sạch
/data/processed/aggregated_by_time/by_hour
/data/processed/aggregated_by_time/by_date
/data/processed/aggregated_by_time/by_dayofweek
/data/processed/aggregated_by_time/by_dow_hour
/data/processed/aggregated_by_vendor/by_vendor
/data/processed/aggregated_by_vendor/by_payment
/data/processed/aggregated_by_vendor/by_pickup_location_top20
/data/processed/aggregated_by_vendor/by_route_top50
```

## Web UI

- NameNode: http://localhost:9870
- YARN: http://localhost:8088

## Troubleshooting

**Incompatible clusterIDs:**
```bash
stop-dfs.sh
rm -rf ~/hadoopdata/namenode/* ~/hadoopdata/datanode/*
hdfs namenode -format
start-dfs.sh
```

**HDFS không kết nối:**
```bash
jps  # kiểm tra NameNode + DataNode
start-dfs.sh
```

**OutOfMemoryError:** tăng `.config('spark.driver.memory', '8g')`

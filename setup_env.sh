#!/bin/bash
# ============================================================
# FILE: setup_env.sh
# MỤC ĐÍCH: Cài đặt toàn bộ môi trường từ A-Z (Ubuntu/WSL2)
# Chạy: bash setup_env.sh
# ============================================================

set -e

echo '=================================================='
echo '  SETUP MÔI TRƯỜNG BIG DATA - NHÓM 4'
echo '=================================================='

# BƯỚC 1: Java 11
echo '[1/6] Cài đặt Java 11...'
sudo apt update -y && sudo apt upgrade -y
sudo apt install openjdk-11-jdk -y
grep -q 'JAVA_HOME' ~/.bashrc || echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
grep -q 'JAVA_HOME' ~/.bashrc || echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
echo "  → $(java -version 2>&1 | head -1)"

# BƯỚC 2: SSH
echo '[2/6] Cấu hình SSH...'
sudo apt install openssh-server -y
[ ! -f ~/.ssh/id_rsa ] && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
sudo service ssh start
echo '  → SSH sẵn sàng'

# BƯỚC 3: Hadoop env vars
echo '[3/6] Cấu hình Hadoop...'
if ! grep -q 'HADOOP_HOME' ~/.bashrc; then
    cat >> ~/.bashrc << 'ENVEOF'
export HADOOP_HOME=~/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENVEOF
fi
mkdir -p ~/hadoopdata/tmp ~/hadoopdata/namenode ~/hadoopdata/datanode
echo '  → Thư mục Hadoop tạo xong'

# BƯỚC 4: Spark 3.5.1
echo '[4/6] Cài đặt Spark 3.5.1...'
if [ ! -d ~/spark ]; then
    cd ~
    wget -q https://downloads.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
    tar -xzf spark-3.5.1-bin-hadoop3.tgz
    mv spark-3.5.1-bin-hadoop3 spark
    rm spark-3.5.1-bin-hadoop3.tgz
fi
if ! grep -q 'SPARK_HOME' ~/.bashrc; then
    cat >> ~/.bashrc << 'ENVEOF'
export SPARK_HOME=~/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=python3
ENVEOF
fi
[ ! -f ~/spark/conf/spark-env.sh ] && cp ~/spark/conf/spark-env.sh.template ~/spark/conf/spark-env.sh
grep -q 'JAVA_HOME' ~/spark/conf/spark-env.sh || echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/spark/conf/spark-env.sh
grep -q 'HADOOP_CONF_DIR' ~/spark/conf/spark-env.sh || echo 'export HADOOP_CONF_DIR=~/hadoop/etc/hadoop' >> ~/spark/conf/spark-env.sh
echo '  → Spark cấu hình xong'

# BƯỚC 5: Python & Jupyter
echo '[5/6] Cài đặt Python & thư viện...'
sudo apt install python3-pip python3-venv -y
[ ! -d ~/bigdata-env ] && python3 -m venv ~/bigdata-env
source ~/bigdata-env/bin/activate
pip install -q -r "$(dirname "$0")/requirements.txt"
echo '  → Python environment sẵn sàng'

# BƯỚC 6: Format NameNode & Start HDFS
echo '[6/6] Format NameNode và khởi động HDFS...'
source ~/.bashrc
export HADOOP_HOME=~/hadoop
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
hdfs namenode -format -force
start-dfs.sh

echo ''
echo '=================================================='
echo '✅ CÀI ĐẶT HOÀN TẤT!'
echo '=================================================='
echo ''
echo 'Kiểm tra: jps  (phải thấy NameNode + DataNode)'
echo 'Web UI:   http://localhost:9870'
echo ''
echo 'Bước tiếp: bash upload_data.sh'

#!/bin/bash
###################################################################
#*名称 --%@NAME:买了又买
#*功能描述 --%@COMMENT:分析数据,得到对应的买了又买的产品
#*来源表 --%@FROM_TABLE:order_product_d
#*目标表  --%@TARGET_TABLE:mysql: bought_also_bought
#*执行周期 人工调用
####################################################################
THIS="$0"

while [ -h "$THIS" ]; do
ls=`ls -ld "$THIS"`
link=`expr "$ls" : '.*-> \(.*\)$'`
if expr "$link" : '.*/.*' > /dev/null; then
THIS="$link"
else
THIS=`dirname "$THIS"`/"$link"
fi
done
THIS_DIR=`dirname "$THIS"`
BIGDATA_HOME=`cd "$THIS_DIR/.." ; pwd`


# if no args specified, show usage
if [ $# -lt 2 ]; then
  echo "Usage: <StartTime> <EndTime>  eg: 20151124 20151130"
  exit 1
fi


startTime=$1
endTime=$2



#SPARK 参数设置
SPARK_MASTER_URL="spark://cidadm01:7077"
PROGRAM_CLASS="popularization.BoughtProduct"
JAR_PATH="${BIGDATA_HOME}/lib/sbtSpark-assembly-1.0.jar"
SPARK_HOME="/usr/lib/spark/spark-1.4.1-bin-hadoop2.4/bin"
#分析
echo "开始分析数据"
$SPARK_HOME/spark-submit --master $SPARK_MASTER_URL --executor-memory 5G --total-executor-cores 24 --class $PROGRAM_CLASS  $JAR_PATH $startTime $endTime

#将hdfs中的数据加载到对应的bought_also_bought表中,不保留原有的数据
hive -e "
use dm_recsys_model;
LOAD DATA INPATH 'popular/product' OVERWRITE INTO TABLE bought_also_bought;
"
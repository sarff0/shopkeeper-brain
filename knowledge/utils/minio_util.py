import os
import logging

from minio.error import S3Error
from minio import Minio
from knowledge.core.paths import load_project_env
load_project_env()


def get_minio_client():
    # 1. 实例化MinIO客户端
    try:
        client = Minio(os.getenv("MINIO_ENDPOINT"),  # 服务端端口
                       access_key=os.getenv("MINIO_ACCESS_KEY"),  # 访问的key
                       secret_key=os.getenv("MINIO_SECRET_KEY"),  # 访问的秘钥
                       secure=False  # 使用HTTP协议
                       )

        # 2. 判断通是否存在
        bucket_name = os.getenv("MINIO_BUCKET_NAME")
        bucket_exists = client.bucket_exists(bucket_name)
        if not bucket_exists:
            client.make_bucket(bucket_name)
            logging.info(f"桶:{bucket_name} 不存在，已自动创建")
        else:
            logging.info(f"桶:{bucket_name} 已经存在")

        # 3. 返回MinIo客户端
        return client
    except Exception as e:
        # 原来只 catch S3Error 且不打印 e：服务器不可达(MaxRetryError 等非 S3 异常)会漏掉，
        # 真正原因也被吞掉。这里放宽并打印异常，返回 None 由调用方安全降级。
        logging.error(f"MinIO客户端创建失败: {e}")
        return None

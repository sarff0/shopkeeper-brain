import os
from dotenv import load_dotenv

# 项目根目录（.当前目录 ..上一层目录）D:\develop\develop\workspace\pycharm\251020\shopkeeper_brain\knowledge
KNOWLEDGE_ROOT=os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# .env 实际位于 knowledge/.env，不能依赖进程当前工作目录查找。
ENV_FILE = os.path.join(KNOWLEDGE_ROOT, ".env")


def load_project_env() -> bool:
    """从项目固定位置加载环境变量。"""
    return load_dotenv(dotenv_path=ENV_FILE, override=False)

# 本地文件存储基础目录
LOCAL_BASE_DIR = os.path.join(KNOWLEDGE_ROOT, "temp_data")

# 前端页面静态资源目录   D:\develop\develop\workspace\pycharm\251020\shopkeeper_brain\knowledge\front
FRONT_PAGE_DIR = os.path.join(KNOWLEDGE_ROOT, "front")

def get_local_base_dir() -> str:
    """获取本地文件存储基础目录"""
    return LOCAL_BASE_DIR


def get_front_page_dir() -> str:
    """获取前端静态页面目录"""
    return FRONT_PAGE_DIR

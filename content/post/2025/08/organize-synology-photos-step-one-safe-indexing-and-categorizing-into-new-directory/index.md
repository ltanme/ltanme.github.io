---
title: "整理群晖照片（第一步）：从源目录安全索引与分类到新目录"
date: 2025-08-31T17:30:00+08:00
draft: false
tags: ["Synology", "DSM7", "Python", "SQLite", "EXIF"]
categories: ["自建服务", "多媒体管理"]
description: "在不改动群晖原始照片目录的前提下，使用 Python + SQLite 将图片/视频扫描入库，按照片、视频、截图三类复制到新目录（支持多线程、断点重跑、记录 MD5、日志追踪）。"
---

> 本文面向 **DSM 7.0** 环境，系统自带 **Python 3.8.8**。我们将在 **不改动源目录** 的前提下，扫描 `/volume2/photo/` 的所有子目录，把图片/视频的元数据写入 SQLite，并按“照片 / 视频 / 截图”分别复制到 `/volume2/newPhoto/` 下的三个子目录，且**同名不覆盖**、**可重复执行**。

---

## 0. 目标概览

- **源目录**（只读）：`/volume2/photo/`
- **目标根目录**：`/volume2/newPhoto/`
  - `video/`：保存视频  
  - `photo/`：保存普通照片  
  - `screenshots/`：保存手机截图（**不靠文件名识别**，使用启发式检测）
- **数据库**：`/volume2/newPhoto/media.db`
- **日志**：
  - 应用日志：`/volume2/newPhoto/organize_media.log`
  - 后台 nohup 输出：`/volume2/newPhoto/organize_media.out`

> 重跑会**跳过已入库的源文件**，你也可以用 `--rescan` 强制重新落盘并更新数据库中的目标路径与 MD5。

---

## 1. 准备 Python 虚拟环境（不污染系统 Python 3.8.8）

```bash
# 进入工具目录（建议放脚本、DB、日志于此）
mkdir -p /volume2/newPhoto/venvs
cd /volume2/newPhoto

# 建立虚拟环境
python3 -m venv /volume2/newPhoto/venvs/py38
source /volume2/newPhoto/venvs/py38/bin/activate

# 若 venv 里没有 pip，则仅给 venv 安装（不动系统 Python）
command -v pip >/dev/null 2>&1 || {
  wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py \
  || curl -L https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
  python /tmp/get-pip.py
}
```

---

## 2. 安装依赖

> 最小依赖只需 `Pillow + exifread`；推荐额外安装 `python-magic` 以提升 MIME 判断准确性（若缺 `libmagic` 会自动回退到 `mimetypes`）。

**`requirements.txt`：**
```txt
Pillow>=8.0.0,<10.0.0
exifread>=3.0.0,<4.0.0
python-magic>=0.4.24,<1.0.0
# 可选：以下两项当前脚本不强依赖，装不上可注释掉
# numpy>=1.19.0,<2.0.0
# piexif>=1.1.3,<2.0.0
```

**安装：**
```bash
pip install -r requirements.txt
```

> 如 `python-magic` 因系统未装 `libmagic` 而失败，脚本会自动回退，不影响主流程。

---

## 3. 放置脚本

将以下完整脚本保存为：`/volume2/newPhoto/organize_media.py`

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
organize_media.py  (DSM 7 / Python 3.8.8)
- 无限级遍历源目录（只读），识别图片/视频/截图
- 复制到目标目录（支持 flat: 单目录；split: video/photo/screenshots 分目录）
- 同名不覆盖：不同内容追加 __{md5前8位}
- SQLite 记录：src_path、dest_path、src_md5、dest_md5、mime、media_type、尺寸、EXIF（时间/GPS/描述/设备/软件）
- 多线程处理；所有 DB 操作用全局锁串行化（修复 sqlite 跨线程报错）
- 日志输出 organize_media.log；可重复执行，默认按 src_path 幂等跳过；--rescan 可强制重新落盘与更新
"""
import argparse, hashlib, logging, mimetypes, os, shutil, sqlite3, sys, time, threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

# 第三方
try:
    import magic  # python-magic，可选
except Exception:
    magic = None
from PIL import Image
import exifread

# ---------------- 基本配置 ----------------
DEFAULT_SRC = "/volume2/photo"
DEFAULT_DST = "/volume2/newPhoto"
DEFAULT_DB  = "media.db"
LOG_FILE    = "organize_media.log"
CHUNK_SIZE  = 8 * 1024 * 1024   # 8MB
IGNORE_DIR_NAMES = {"@eaDir", "#recycle", "#Recycle", "venvs"}

VIDEO_EXT_FALLBACK = {".mp4",".mov",".avi",".mkv",".flv",".wmv",".mts",".m2ts",".3gp",".mpg",".mpeg",".rmvb"}
IMAGE_EXT_FALLBACK = {".jpg",".jpeg",".png",".webp",".bmp",".tiff",".gif",".heic",".heif"}

COMMON_SCREEN_SIDES = {
    720,1080,1125,1170,1242,1284,1344,1440,1600,2160,2208,2224,2246,2280,
    2316,2340,2400,2460,2560,2688,2732,2796,2840,2960,3088,3120,3200
}

# ---------------- 日志 ----------------
def setup_logger():
    lg = logging.getLogger("organize_media")
    lg.setLevel(logging.INFO); lg.propagate = False
    if not lg.handlers:
        fmt = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
        ch = logging.StreamHandler(sys.stdout); ch.setLevel(logging.INFO); ch.setFormatter(fmt); lg.addHandler(ch)
        fh = logging.FileHandler(LOG_FILE, encoding="utf-8"); fh.setLevel(logging.INFO); fh.setFormatter(fmt); lg.addHandler(fh)
    return lg
log = setup_logger()

# ---------------- DB（跨线程安全） ----------------
DB_LOCK = threading.RLock()
SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS files(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  src_path TEXT NOT NULL UNIQUE,
  src_md5 TEXT,
  src_size_bytes INTEGER,
  mime TEXT,
  media_type TEXT,  -- video | photo | screenshot | other
  width INTEGER, height INTEGER,
  exif_datetime TEXT, gps_lat REAL, gps_lng REAL,
  desc TEXT, make TEXT, model TEXT, software TEXT,
  dest_path TEXT, dest_md5 TEXT,
  processed_at TEXT DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS errors(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  src_path TEXT, error TEXT, created_at TEXT DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_files_src_md5  ON files(src_md5);
CREATE INDEX IF NOT EXISTS idx_files_dest_md5 ON files(dest_md5);
"""

def get_db(db_path: Path):
    conn = sqlite3.connect(str(db_path), check_same_thread=False, timeout=30.0)
    with DB_LOCK:
        conn.execute("PRAGMA journal_mode=WAL;")
        conn.execute("PRAGMA synchronous=NORMAL;")
        conn.executescript(SCHEMA_SQL)
    return conn

def upsert_file_row(conn, row: dict):
    cols = ", ".join(row.keys())
    qs   = ", ".join(["?"]*len(row))
    sql = f"""INSERT INTO files({cols}) VALUES({qs})
              ON CONFLICT(src_path) DO UPDATE SET
                src_md5=excluded.src_md5,
                src_size_bytes=excluded.src_size_bytes,
                mime=excluded.mime,
                media_type=excluded.media_type,
                width=excluded.width,
                height=excluded.height,
                exif_datetime=excluded.exif_datetime,
                gps_lat=excluded.gps_lat,
                gps_lng=excluded.gps_lng,
                desc=excluded.desc,
                make=excluded.make,
                model=excluded.model,
                software=excluded.software"""
    with DB_LOCK:
        conn.execute(sql, list(row.values()))

def update_dest(conn, src_path: str, dest_path: str, dest_md5: str):
    with DB_LOCK:
        conn.execute("UPDATE files SET dest_path=?, dest_md5=? WHERE src_path=?", (dest_path, dest_md5, src_path))

def src_exists(conn, src_path: str) -> bool:
    with DB_LOCK:
        cur = conn.execute("SELECT 1 FROM files WHERE src_path=? LIMIT 1", (src_path,))
        return cur.fetchone() is not None

def insert_error(conn, src_path: str, err: str):
    with DB_LOCK:
        conn.execute("INSERT INTO errors(src_path, error) VALUES(?,?)", (src_path, err[:1000]))

def db_commit(conn):
    with DB_LOCK:
        conn.commit()

# ---------------- 工具 ----------------
def file_md5(p: Path) -> str:
    h = hashlib.md5()
    with p.open("rb") as f:
        while True:
            b = f.read(CHUNK_SIZE)
            if not b: break
            h.update(b)
    return h.hexdigest()

def guess_mime(p: Path) -> str:
    if magic is not None:
        try:
            m = magic.from_file(str(p), mime=True)
            if m: return m
        except Exception: pass
    mt, _ = mimetypes.guess_type(str(p))
    return mt or "application/octet-stream"

def is_video(mime: str, ext: str) -> bool:
    return (mime and mime.startswith("video/")) or (ext in VIDEO_EXT_FALLBACK)

def is_image(mime: str, ext: str) -> bool:
    return (mime and mime.startswith("image/")) or (ext in IMAGE_EXT_FALLBACK)

def get_image_size(p: Path):
    try:
        with Image.open(str(p)) as im:
            return im.width, im.height, im.info
    except Exception:
        return None, None, {}

def dms_to_deg(dms, ref):
    try:
        d = float(dms[0].num)/float(dms[0].den)
        m = float(dms[1].num)/float(dms[1].den)
        s = float(dms[2].num)/float(dms[2].den)
        deg = d + m/60.0 + s/3600.0
        return -deg if ref in ("S","W") else deg
    except Exception:
        return None

def read_exif(p: Path):
    try:
        with p.open("rb") as f:
            tags = exifread.process_file(f, details=False)
    except Exception:
        return {}, {}
    get = lambda k: str(tags.get(k, "")).strip()
    ex = {
        "exif_datetime": get("EXIF DateTimeOriginal") or get("Image DateTime"),
        "desc": get("Image ImageDescription") or get("EXIF UserComment"),
        "make": get("Image Make"),
        "model": get("Image Model"),
        "software": get("Image Software"),
        "gps_lat": None, "gps_lng": None
    }
    lat_t = tags.get("GPS GPSLatitude");  lat_ref = str(tags.get("GPS GPSLatitudeRef",""))
    lng_t = tags.get("GPS GPSLongitude"); lng_ref = str(tags.get("GPS GPSLongitudeRef",""))
    if lat_t and lng_t and lat_ref and lng_ref:
        ex["gps_lat"] = dms_to_deg(lat_t.values, lat_ref)
        ex["gps_lng"] = dms_to_deg(lng_t.values, lng_ref)
    return tags, ex

def is_screenshot(mime: str, w: int, h: int, exif_sel: dict, pil_info: dict) -> bool:
    if not w or not h: return False
    score = 0
    ml = (mime or "").lower()
    soft = (exif_sel.get("software") or "").lower()
    if ml in ("image/png","image/webp"): score += 1
    if not (exif_sel.get("make") or exif_sel.get("model") or exif_sel.get("exif_datetime")): score += 1
    if "screenshot" in soft or ("screen" in soft and ("cap" in soft or "shot" in soft)): score += 2
    if w in COMMON_SCREEN_SIDES or h in COMMON_SCREEN_SIDES: score += 1
    ar = w / float(h)
    if 1.6 <= ar <= 2.4 or 0.45 <= ar <= 0.6: score += 1
    dpi = pil_info.get("dpi") if isinstance(pil_info, dict) else None
    if dpi and isinstance(dpi, tuple) and any(x in (72,96) for x in dpi if isinstance(x,(int,float))): score += 0.5
    return score >= 2

def ensure_dir(p: Path): p.mkdir(parents=True, exist_ok=True)

def safe_copy(src: Path, dest_dir: Path, src_md5: str) -> Path:
    ensure_dir(dest_dir)
    target = dest_dir / src.name
    if target.exists():
        try:
            if file_md5(target) == src_md5:
                return target
        except Exception:
            pass
        alt = dest_dir / f"{target.stem}__{src_md5[:8]}{target.suffix}"
        shutil.copy2(str(src), str(alt))
        return alt
    shutil.copy2(str(src), str(target))
    return target

def resolve_dest_dir(dst_root: Path, media_type: str, mode: str) -> Path:
    if mode == "flat":
        return dst_root
    mapping = {"video":"video", "photo":"photo", "screenshot":"screenshots"}
    sub = mapping.get(media_type)
    return dst_root / sub if sub else dst_root

# ---------------- 遍历（无限级） ----------------
def walk_files(src: Path, dst_root: Path):
    src = src.resolve(); dst_root = dst_root.resolve()
    for root, dirs, files in os.walk(src, followlinks=False):
        root_path = Path(root).resolve()
        try:
            if dst_root in root_path.parents or root_path == dst_root:
                continue
        except Exception: pass
        pruned = []
        for d in dirs:
            if d in IGNORE_DIR_NAMES: continue
            if d.lower() in {"@eadir","#recycle","#recycle.bin"}: continue
            if (root_path / d).resolve() == dst_root: continue
            pruned.append(d)
        dirs[:] = pruned
        for fn in files:
            if fn.startswith(".") or fn.endswith("~"): continue
            yield (root_path / fn)

# ---------------- 核心处理 ----------------
def process_one(p: Path, dst_root: Path, conn: sqlite3.Connection, mode: str, rescan: bool):
    src_path = str(p)
    try:
        st = p.stat()
        src_md5 = file_md5(p)
        mime = guess_mime(p)
        ext  = p.suffix.lower()

        media_type = "other"; w = h = None; exif_sel = {}; pil_info = {}
        if (mime and mime.startswith("video/")) or (ext in VIDEO_EXT_FALLBACK):
            media_type = "video"
        elif (mime and mime.startswith("image/")) or (ext in IMAGE_EXT_FALLBACK):
            w,h,pil_info = get_image_size(p)
            _, exif_sel  = read_exif(p)
            media_type = "screenshot" if is_screenshot(mime,w,h,exif_sel,pil_info) else "photo"

        upsert_file_row(conn, {
            "src_path": src_path,
            "src_md5": src_md5,
            "src_size_bytes": st.st_size,
            "mime": mime,
            "media_type": media_type,
            "width": w, "height": h,
            "exif_datetime": exif_sel.get("exif_datetime"),
            "gps_lat": exif_sel.get("gps_lat"),
            "gps_lng": exif_sel.get("gps_lng"),
            "desc": exif_sel.get("desc"),
            "make": exif_sel.get("make"),
            "model": exif_sel.get("model"),
            "software": exif_sel.get("software"),
            "dest_path": None, "dest_md5": None
        })

        if media_type in ("video","photo","screenshot"):
            if not rescan:
                with DB_LOCK:
                    cur = conn.execute("SELECT dest_path FROM files WHERE src_path=? LIMIT 1", (src_path,))
                    row = cur.fetchone()
                if row and row[0]:
                    return "skip", src_path

            dest_dir = resolve_dest_dir(dst_root, media_type, mode)
            dest = safe_copy(p, dest_dir, src_md5)
            try:
                dest_md5 = file_md5(dest)
            except Exception:
                dest_md5 = None
            update_dest(conn, src_path, str(dest), dest_md5)
            return media_type, src_path
        else:
            return "other", src_path

    except Exception as e:
        insert_error(conn, src_path, repr(e))
        log.exception(f"[ERROR] {src_path}: {e}")
        return "error", src_path

# ---------------- 主程序 ----------------
def main():
    ap = argparse.ArgumentParser(description="Index photo/video to SQLite and copy into flat/split dirs.")
    ap.add_argument("--src", default=DEFAULT_SRC, help="源目录（只读）")
    ap.add_argument("--dst", default=DEFAULT_DST, help="目标根目录（flat时直接落在此目录；split时在其下建子目录）")
    ap.add_argument("--db",  default=DEFAULT_DB,  help="SQLite 文件名（默认当前目录 media.db）")
    ap.add_argument("--mode", choices=["flat","split"], default="flat", help="flat=单目录; split=video/photo/screenshots 分目录")
    ap.add_argument("--rescan", action="store_true", help="忽略已处理记录，强制重新复制并更新 dest_*")
    ap.add_argument("--workers", type=int, default=max(2, (os.cpu_count() or 2)//2), help="并发线程数")
    args = ap.parse_args()

    src = Path(args.src).resolve()
    dst = Path(args.dst).resolve()
    dst.mkdir(parents=True, exist_ok=True)

    conn = get_db(Path(args.db).resolve())
    log.info(f"=== Start === src={src} dst={dst} db={args.db} mode={args.mode} rescan={args.rescan} workers={args.workers}")

    done = 0
    stats = {"video":0,"photo":0,"screenshot":0,"other":0,"skip":0,"error":0}
    t0 = time.time()

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        pending = []
        for fp in walk_files(src, dst):
            pending.append(ex.submit(process_one, fp, dst, conn, args.mode, args.rescan))
            if len(pending) >= args.workers * 1000:
                for fut in as_completed(pending[:args.workers * 200]):
                    kind, _ = fut.result(); stats[kind]=stats.get(kind,0)+1; done+=1
                    if done % 200 == 0:
                        db_commit(conn)
                        log.info(f"进度 {done} | 统计 {stats}")
                pending = pending[args.workers * 200:]

        for fut in as_completed(pending):
            kind, _ = fut.result(); stats[kind]=stats.get(kind,0)+1; done+=1
        db_commit(conn)

    log.info(f"=== Done in {time.time()-t0:.1f}s === 已处理 {done} | 统计 {stats}")

if __name__ == "__main__":
    main()
```

> 若脚本不可执行：`chmod +x /volume2/newPhoto/organize_media.py`

---

## 4. 运行（后台）

**分三类存放（推荐）**：
```bash
( cd /volume2/newPhoto && nohup /volume2/newPhoto/venvs/py38/bin/python /volume2/newPhoto/organize_media.py \
  --src /volume2/photo --dst /volume2/newPhoto --db /volume2/newPhoto/media.db \
  --mode split --rescan --workers 4 > /volume2/newPhoto/organize_media.out 2>&1 & )
```

> - `--mode split`：落到 `video/`、`photo/`、`screenshots/`  
> - `--rescan`：即使已有记录也重新复制并更新 `dest_path`/`dest_md5`  
> - `--workers 4`：并发线程数，视 NAS 性能调整  
> - 源目录**只读**，脚本使用 `copy2` 保持时间戳与权限

---

## 5. 查看进度与日志

```bash
# 实时日志
tail -f /volume2/newPhoto/organize_media.log
# nohup 输出
tail -f /volume2/newPhoto/organize_media.out

# 进程检查
pgrep -af /volume2/newPhoto/organize_media.py
```

---

## 6. 验证数据库

```bash
# 每类文件的总数 & 已落盘数
sqlite3 /volume2/newPhoto/media.db \
"SELECT media_type, COUNT(*), SUM(dest_path IS NOT NULL) FROM files GROUP BY media_type;"

# 看几条映射（源/目标/MD5）
sqlite3 /volume2/newPhoto/media.db \
"SELECT substr(src_md5,1,8), substr(dest_md5,1,8), src_path, dest_path FROM files WHERE dest_path IS NOT NULL LIMIT 5;"

# 错误数量
sqlite3 /volume2/newPhoto/media.db "SELECT COUNT(*) FROM errors;"
```

> 由于启用 **WAL 模式**，数据会先写入 `media.db-wal`；主库 `media.db` 体积可能暂不变化，属正常行为。

**需要将 WAL 合并入主库（可选）：**
```bash
sqlite3 /volume2/newPhoto/media.db "PRAGMA wal_checkpoint(TRUNCATE); VACUUM;"
```

---

## 7. 使用说明与特性

- **同名不覆盖**：若目标已有同名文件但内容不同，自动保存为 `原名__{md5前8位}.扩展名`，两者都保留。
- **截图识别**：不依赖文件名；综合 MIME、EXIF 缺失、尺寸/纵横比、DPI、软件标记等启发式。
- **可重复执行**：默认按 `src_path` 幂等跳过；加 `--rescan` 可强制更新。
- **多线程**：`ThreadPoolExecutor` 并发处理；DB 访问串行化避免线程问题。
- **安全**：不修改源目录内容；复制目标位于 `/volume2/newPhoto/`。

---

## 8. 常见问题

**Q1：数据库文件 `media.db` 一直 4096B？**  
A：WAL 模式下，数据写在 `media.db-wal`，主库体积不会立刻变大。执行：
```bash
sqlite3 /volume2/newPhoto/media.db "PRAGMA wal_checkpoint(TRUNCATE); VACUUM;"
```

**Q2：看到 `sqlite3.ProgrammingError: SQLite objects created in a thread …`？**  
A：本教程脚本已设置 `check_same_thread=False` 且用 `DB_LOCK` 串行化 SQL。若仍看到，通常是**旧进程**在跑：  
```bash
pkill -f "/volume2/newPhoto/organize_media.py"
# 然后用上面的 nohup 命令重启
```

**Q3：目录权限显示一堆 `+` 或 `---------+` 正常吗？**  
A：群晖启用 **ACL** 时，`ls -l` 的 POSIX 权限不代表最终权限。可用：
```bash
synoacltool -get /volume2/newPhoto
ls -le /volume2/newPhoto
```
必要时再 `chown/chmod` 微调显示，但最终以 ACL 为准。

---

## 9. 下一步（可选扩展）

- **去重策略**：若不同源路径 MD5 相同，可只保留目标一份并在 DB 中记录多对一映射。  
- **按日期分层**：`photo/YYYY/YYYY-MM/` 归档。  
- **导出报表**：将 `files` 表导出为 CSV/Markdown，便于审阅。

> 如果你需要上述扩展，我可以提供直接可用的增量脚本与 SQL 示例。

---
**至此，你已完成“整理群晖照片（第一步）”：安全索引 + 分类复制 + 可追踪元数据。**

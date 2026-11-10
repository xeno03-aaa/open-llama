# open-llama-gpu 镜像发布

本 Release 附带 GPU 版 open-llama 的 Docker 镜像导出文件（`docker save` 产物）。

由于 GitHub Release 单文件上限为 2 GiB，而原始 tar 为 3.41 GiB（3,661,595,136 字节），
文件被切分为 2 个分片上传。

## 下载并还原

```bash
# 1. 下载全部分片到同一目录
#    open-llama-gpu.tar.part0
#    open-llama-gpu.tar.part1

# 2. 按序拼接还原
cat open-llama-gpu.tar.part0 open-llama-gpu.tar.part1 > open-llama-gpu.tar

# 3. 校验（应输出与下方一致的哈希）
sha256sum open-llama-gpu.tar
```

## 加载镜像

```bash
docker load -i open-llama-gpu.tar
docker images   # 确认镜像已出现
```

## 校验值

见 Release 说明正文中的 SHA-256。

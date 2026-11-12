# open-llama 镜像发布

本仓库 Release 附带 CPU / GPU 两版 open-llama 的 Docker 镜像导出文件（`docker save` 后 gzip 压缩）。

| 版本 | 镜像标签 | 文件 | 字节 |
| --- | --- | --- | --- |
| CPU `v1.1.1-cpu` | `open-llama:cpu-latest` | `open-llama-cpu.tar.gz` | 53,062,505 |
| GPU `v1.1.1-gpu` | `open-llama:gpu-latest` | `open-llama-gpu.tar.gz.part0` + `.part1` | 2,384,543,640 |

GitHub Release 单文件上限为 2 GiB，GPU 压缩包超过该限制，切分为 2 个分片。

## 下载并还原

### CPU

```bash
# 1. 下载 open-llama-cpu.tar.gz
# 2. 校验
sha256sum open-llama-cpu.tar.gz
#    应为 056d99c9f9f4eaf0a2b7e771b4f38bf601dab0e7390104d064ab41234cc4e30f
# 3. 加载
docker load -i open-llama-cpu.tar.gz
```

### GPU

```bash
# 1. 下载全部分片到同一目录
#    open-llama-gpu.tar.gz.part0
#    open-llama-gpu.tar.gz.part1

# 2. 按序拼接
cat open-llama-gpu.tar.gz.part0 open-llama-gpu.tar.gz.part1 > open-llama-gpu.tar.gz

# 3. 校验（应输出与下方一致的哈希）
sha256sum open-llama-gpu.tar.gz

# 4. 加载
docker load -i open-llama-gpu.tar.gz
```

## 校验值

拼接后完整文件的 SHA-256：

```
GPU  2,384,543,640 字节  2d4115527069299eacaa1b43d3e16563eddc41834fa79bb570e55da52a783415
CPU     53,062,505 字节  056d99c9f9f4eaf0a2b7e771b4f38bf601dab0e7390104d064ab41234cc4e30f
```

GPU 分片单独校验：

| 文件 | 字节 | SHA-256 |
| --- | --- | --- |
| `open-llama-gpu.tar.gz.part0` | 1,258,291,200 | `3c4f4b8dca12af0d3b842aa0b1b255aad1e8abff380ac37449c2064050dcc02e` |
| `open-llama-gpu.tar.gz.part1` | 1,126,252,440 | `8f904885294cfb49d6f1fbe843bed3e720012cfe1a68606542d86415633c85c2` |

详见各 Release 说明正文。

## 加载后

```bash
docker images | grep open-llama
# open-llama   cpu-latest   ...   141MB
# open-llama   gpu-latest   ...   3.69GB
```

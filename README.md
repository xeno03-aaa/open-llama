# open-llama 镜像发布

本仓库 Release 附带 CPU / GPU 两版 open-llama 的 Docker 镜像导出文件（`docker save` 后 gzip 压缩）。

| 版本 | 镜像标签 | 文件 | 字节 |
| --- | --- | --- | --- |
| CPU `v1.1.0-cpu` | `open-llama:cpu-latest` | `open-llama-cpu.tar.gz` | 53,055,265 |
| GPU `v1.1.0-gpu` | `open-llama:gpu-latest` | `open-llama-gpu.tar.gz.part0` + `.part1` | 2,384,541,319 |

GitHub Release 单文件上限为 2 GiB，GPU 压缩包超过该限制，切分为 2 个分片。

## 下载并还原

### CPU

```bash
# 1. 下载 open-llama-cpu.tar.gz
# 2. 校验
sha256sum open-llama-cpu.tar.gz
#    应为 cd83c86066137cb129d9bbf15c5086fc03e80078aec26f59ce158435a775798a
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
GPU  2,384,541,319 字节  bc698e697fb8ca521e7f9802a5a233b5993fd9035ebc938595feb3d6280f9074
CPU     53,055,265 字节  cd83c86066137cb129d9bbf15c5086fc03e80078aec26f59ce158435a775798a
```

GPU 分片单独校验：

| 文件 | 字节 | SHA-256 |
| --- | --- | --- |
| `open-llama-gpu.tar.gz.part0` | 1,258,291,200 | `a6d7f61655eb9ccf34ba7131bd93f18f3cb1fa77ce8efcbe618ac85dc301eb67` |
| `open-llama-gpu.tar.gz.part1` | 1,126,250,119 | `c54f3678a278448dac8e72cddd6972ee155444ca3a2acfc424abbb84a5cc7240` |

详见各 Release 说明正文。

## 加载后

```bash
docker images | grep open-llama
# open-llama   cpu-latest   ...   141MB
# open-llama   gpu-latest   ...   3.69GB
```

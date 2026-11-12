# open-llama 镜像分发

CPU / GPU 两版 open-llama 的 Docker 镜像导出文件（`docker save` 后 gzip 压缩），托管在 Cloudflare R2，直链下载。

| 版本 | 镜像标签 | 文件 | 字节 |
| --- | --- | --- | --- |
| CPU | `open-llama:cpu-latest` | `open-llama-cpu.tar.gz` | 53,062,505 |
| GPU | `open-llama:gpu-latest` | `open-llama-gpu.tar.gz` | 2,384,543,640 |

两个文件都是**整包**，不需要拼接分片。

## 下载地址

```
https://pub-fb82cd711d634d6097240add90d69fe1.r2.dev/open-llama/v1.1.1/open-llama-cpu.tar.gz
https://pub-fb82cd711d634d6097240add90d69fe1.r2.dev/open-llama/v1.1.1/open-llama-gpu.tar.gz
```

## 下载并加载

```bash
# CPU
curl -LO https://pub-fb82cd711d634d6097240add90d69fe1.r2.dev/open-llama/v1.1.1/open-llama-cpu.tar.gz
sha256sum open-llama-cpu.tar.gz
#   应为 056d99c9f9f4eaf0a2b7e771b4f38bf601dab0e7390104d064ab41234cc4e30f
docker load -i open-llama-cpu.tar.gz

# GPU
curl -LO https://pub-fb82cd711d634d6097240add90d69fe1.r2.dev/open-llama/v1.1.1/open-llama-gpu.tar.gz
sha256sum open-llama-gpu.tar.gz
#   应为 2d4115527069299eacaa1b43d3e16563eddc41834fa79bb570e55da52a783415
docker load -i open-llama-gpu.tar.gz
```

`docker load` 直接识别 gzip，不用先解压。

## 校验值

| 文件 | 字节 | SHA-256 |
| --- | --- | --- |
| `open-llama-cpu.tar.gz` | 53,062,505 | `056d99c9f9f4eaf0a2b7e771b4f38bf601dab0e7390104d064ab41234cc4e30f` |
| `open-llama-gpu.tar.gz` | 2,384,543,640 | `2d4115527069299eacaa1b43d3e16563eddc41834fa79bb570e55da52a783415` |

## 加载后

```bash
docker images | grep open-llama
# open-llama   cpu-latest   ...   141MB
# open-llama   gpu-latest   ...   3.69GB
```

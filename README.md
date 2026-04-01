# Antigravity-Server-Centos7-Simple
English | 中文
--- | ---
Patch Antigravity Server to run on RHEL/CentOS 7 style systems. | 为 Antigravity Server 修补，使得可以在 RHEL/CentOS 7 类系统运行。

## Quick Start | 快速开始
This project patches an existing server installation. If `~/.antigravity-server` does not exist yet, run the first Antigravity connection or use `scripts/install-from-tarball.sh` first.  
这个项目用于修补已经存在的服务端安装。如果 `~/.antigravity-server` 还不存在，请先完成一次 Antigravity 首次连接，或者先使用 `scripts/install-from-tarball.sh` 安装。

After each local Antigravity upgrade, run this on the remote server:  
每次本地升级 Antigravity 后，在远端服务器执行：

```bash
cd ~/antigravity-server-centos7-simple
chmod +x ./antigravity-server-centos7-simple.sh ./scripts/*.sh
sed -i 's/\r$//' ./antigravity-server-centos7-simple.sh ./scripts/*.sh
./antigravity-server-centos7-simple.sh
```

## Defaults | 默认路径
- `ANTIGRAVITY_SERVER_DIR=~/.antigravity-server`
- `ANTIGRAVITY_GNU_DIR=~/.vscode-server/gnu`

## Custom Paths | 自定义路径
```bash
ANTIGRAVITY_SERVER_DIR=/path/to/.antigravity-server \
ANTIGRAVITY_GNU_DIR=/path/to/gnu \
./antigravity-server-centos7-simple.sh
```

## Requirements | 程序依赖
- `patchelf` available in `PATH`  
  `PATH` 中可用 `patchelf`
- Existing server files under `ANTIGRAVITY_SERVER_DIR`, unless you install from tarball first  
  `ANTIGRAVITY_SERVER_DIR` 下需要已有服务端文件，除非你先走 tarball 安装流程
- GNU runtime files present in `ANTIGRAVITY_GNU_DIR`  
  `ANTIGRAVITY_GNU_DIR` 中包含 GNU 运行文件

## What It Does | 脚本逻辑
1. Copies GNU runtime files into `<server-dir>/gnu` when needed.  
   将 GNU 运行时文件复制到 `<server-dir>/gnu`。
2. Patches ELF interpreter from system loader to bundled loader.  
   将 ELF interpreter 从系统 loader 改为项目内置 loader。
3. Best-effort creates skip-check flags in `/tmp`:  
   尽量在 `/tmp` 下创建跳过检查标记：
   - `/tmp/vscode-skip-server-requirements-check`
   - `/tmp/antigravity-skip-server-requirements-check`

## Scripts | 脚本说明
- `antigravity-server-centos7-simple.sh`: one-command entrypoint | 一键注入脚本
- `scripts/patch-antigravity-server.sh`: core patch logic | 核心补丁
- `scripts/install-from-tarball.sh`: install from tarball then patch | 从 tarball 安装并修补
- `scripts/bundle-gnu-runtime.sh`: copy runtime files into `<server-dir>/gnu` | 复制到 `<server-dir>/gnu`
- `scripts/list-elf-interpreters.sh`: inspect current ELF interpreters | 查看当前 ELF interpreter

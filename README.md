# antigravity-server-centos7-simple

English | 中文
--- | ---
Patch Antigravity Server to run on RHEL/CentOS 7 style systems. | 为 Antigravity Server 提供补丁，使其可在 RHEL/CentOS 7 类系统运行。

## Quick Start | 快速开始

After each local upgrade, run this on the remote server:  
每次本地升级后，在远端服务器执行：

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

## Requirements | 依赖

- `patchelf` available in `PATH`  
  `PATH` 中可用 `patchelf`
- GNU runtime files present in `ANTIGRAVITY_GNU_DIR`  
  `ANTIGRAVITY_GNU_DIR` 中包含 GNU 运行时文件

## What It Does | 执行内容

1. Copies GNU runtime files into `<server-dir>/gnu` when needed.  
   按需将 GNU 运行时文件复制到 `<server-dir>/gnu`。
2. Patches ELF interpreter from system loader to bundled loader.  
   将 ELF interpreter 从系统 loader 改为项目内置 loader。
3. Best-effort creates skip-check flags in `/tmp`:  
   尽力在 `/tmp` 下创建跳过检查标记：
   - `/tmp/vscode-skip-server-requirements-check`
   - `/tmp/antigravity-skip-server-requirements-check`

## Scripts | 脚本说明

- `antigravity-server-centos7-simple.sh`: one-command entrypoint | 一键入口脚本
- `scripts/patch-antigravity-server.sh`: core patch logic | 核心补丁逻辑
- `scripts/install-from-tarball.sh`: install from tarball then patch | 从 tarball 安装后再打补丁
- `scripts/bundle-gnu-runtime.sh`: copy runtime files into `<server-dir>/gnu` | 将运行时复制到 `<server-dir>/gnu`
- `scripts/list-elf-interpreters.sh`: inspect current ELF interpreters | 查看当前 ELF interpreter

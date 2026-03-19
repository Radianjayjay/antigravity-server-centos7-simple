# antigravity-server-centos7-simple

A specially patched Antigravity Server that runs on RHEL/CentOS 7.

## One command after each local upgrade

On server:

```bash
cd ~/antigravity-server-centos7-simple
chmod +x ./antigravity-server-centos7-simple.sh ./scripts/*.sh
sed -i 's/\r$//' ./antigravity-server-centos7-simple.sh ./scripts/*.sh
./antigravity-server-centos7-simple.sh
```

Defaults:

- Server dir: `~/.antigravity-server`
- GNU runtime dir: `~/.vscode-server/gnu`

Override with env vars if needed:

```bash
ANTIGRAVITY_SERVER_DIR=/path/to/.antigravity-server \
ANTIGRAVITY_GNU_DIR=/path/to/gnu \
./antigravity-server-centos7-simple.sh
```

## What it does

1. Ensures runtime loader files exist under `~/.antigravity-server/gnu`.
2. Patches ELF interpreter to bundled loader.
3. Best-effort creates skip-check files in `/tmp`.

## Scripts

- `antigravity-server-centos7-simple.sh`: one-command entrypoint.
- `scripts/patch-antigravity-server.sh`: core patch logic.
- `scripts/install-from-tarball.sh`: install from tarball then patch.
- `scripts/bundle-gnu-runtime.sh`: copy runtime files into `<server-dir>/gnu`.
- `scripts/list-elf-interpreters.sh`: inspect interpreter values.

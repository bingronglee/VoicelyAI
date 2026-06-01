#!/bin/bash
set -e

# 以 root 执行权限修正
chown -R appuser:appuser /app/data

# 降级为 appuser 执行 CMD
exec gosu appuser "$@"

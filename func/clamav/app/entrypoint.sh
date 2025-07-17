#!/bin/bash

touch $0.start
freshclam

python3 -m venv fsdh && . fsdh/bin/activate && \
    pip install -r ./requirements.txt  --target=".python_packages/lib/site-packages" --no-cache-dir --upgrade && \
    python3 scan_blob.py
#!/bin/sh

python mb-tool/apply_mapping.py serial/codemap/$1.json serial/keymap/$2.json $3 | awk -f serial/add_stem.awk

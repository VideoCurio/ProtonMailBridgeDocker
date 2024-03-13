#!/usr/bin/env bash

# Fix bug https://github.com/mattn/go-sqlite3/pull/1177 before make stage

echo "Fixing bug 1177..."

sed -i '/replace (/a github.com/mattn/go-sqlite3 => github.com/leso-kn/go-sqlite3 v0.0.0-20230710125852-03158dc838ed' /build/proton-bridge/go.mod

cd /build/proton-bridge/ || exit
go mod tidy

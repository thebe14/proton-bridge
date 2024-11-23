#!/bin/bash

echo "Building..."
sudo -E docker compose up -d --build --remove-orphans

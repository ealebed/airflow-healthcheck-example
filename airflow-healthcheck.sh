#!/bin/bash

curl -s http://127.0.0.1:8080/health | jq -e '.scheduler.status == "healthy"'

#!/bin/bash

docker build --rm --no-cache \
    --progress plain \
    --file dockerfile.alpine \
    --tag gakiteri/mineserver:jdk17 .

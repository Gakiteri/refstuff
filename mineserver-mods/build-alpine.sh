#!/bin/bash

docker build --rm \
    --file dockerfile.alpine \
    --tag gakiteri/mineserver:jdk8 .

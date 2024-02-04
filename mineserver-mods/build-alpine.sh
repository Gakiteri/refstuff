#!/bin/bash

docker build --rm --no-cache \
    --file dockerfile.alpine \
    --tag gakiteri/mineserver:ojdk21 .

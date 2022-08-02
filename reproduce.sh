#!/bin/bash
set -o xtrace

{
    echo "************************* Starting Docker registry *************************"
    registry_mount=$(pwd)/registry
    docker run -d -p 5000:5000 -v $registry_mount:/var/lib/registry --restart=always --name registry registry:2

    echo "************************* Building initial image *************************"
    docker system prune -af
    docker images -a
    docker build -t localhost:5000/cache-experiments:1 --build-arg BUILDKIT_INLINE_CACHE=1 .
    docker push localhost:5000/cache-experiments:1

    echo "************************* Changing the Docker context *************************"
    echo import os > src/temp.py

    echo "************************* Building the second image *************************"
    docker system prune -af
    docker images -a
    docker build -t localhost:5000/cache-experiments:2 --cache-from localhost:5000/cache-experiments:1 --build-arg BUILDKIT_INLINE_CACHE=1 .
    docker push localhost:5000/cache-experiments:2

    echo "************************* Changing the Docker context *************************"
    rm -f src/temp.py

    echo "************************* Building the third image *************************"
    docker system prune -af
    docker images -a
    docker build -t localhost:5000/cache-experiments:3 --cache-from localhost:5000/cache-experiments:2 --build-arg BUILDKIT_INLINE_CACHE=1 .
}

rm -rf $registry_mount
docker rm -vf registry
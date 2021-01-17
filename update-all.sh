#!/bin/bash

echo "[$0] ***** Pulling all images... *****"
docker-compose pull
echo "[$0] ***** Recreating containers if required... *****"
docker-compose up -d
echo "[$0] ***** Removing old, unused images... *****"
docker image prune -f
echo "[$0] ***** Done. *****"
exit 0

# Development
# freeze at version 7.2.1
docker run \
  -p 9000:9000 -p 9009:9009 -p 8812:8812 -p 9003:9003 \
  -v "$(pwd)/volumes/questdb:/var/lib/questdb" \
  questdb/questdb:7.2.1
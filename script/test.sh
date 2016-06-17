#!/usr/bin/env bash

# test

# selector='<Connector port="8080" protocol="HTTP/1.1"'
# addition='URIEncoding="UTF-8"'
# echo $selector
# sed -i '' -e '/<Connector port=\"8080\" protocol=\"HTTP\/1.1\"/ a\
# \         URIEncoding="UTF-8"' test.txt

# sed -i '' 's/^[[:space:].*<theme .*/GONE/' test.txt

# sed -i '' 's/^[[:space:]]*<theme .*/<!-- & -->/' test.txt
# sed -i '' -e '/<\/themes>/ i\
# \      <theme name="Mirage 2" regex=".*" path="Mirage2\/" \/>' test.txt
sed -i '' -e '/^\# TYPE/ a\
host   dspace             dspace        127.0.0.1\/32            md5' test.txt

#!/bin/bash

echo "Content-Type: text/plain"
echo ""

(find $QUERY_STRING -path "*.svn" -prune -o -user web -type d -exec chmod 755 {} + && find $QUERY_STRING -path "*.svn" -prune -o -user web -type f -exec chmod 644 {} + && find "$QUERY_STRING"wp-content/ -path "*.svn" -prune -o -mindepth 1 -user web -exec chmod 775 {} + && echo 0) || echo 1

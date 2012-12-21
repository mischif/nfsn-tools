#!/bin/bash

echo "Content-Type: text/plain"
echo ""

(find $QUERY_STRING -path "*.svn" -prune -o -user web -exec chgrp web {} + -exec chmod ug+rwx {} + && echo 0) || echo 1

#!/bin/bash

imgdir="this-month"
cd $imgdir

file="toggl-metric.html"

cat >$file <<EOF
<html>
    <head>
        <title>Reporting this month</title>
        <meta charset="UTF-8">
    </head>
    <body>
EOF

for i in $(ls *.png); do
  echo "<$imgdir src=\"$i\" width=\"100%\">" >> $file
done

cat >>$file <<EOF
    </body>
</html>
EOF

cd -
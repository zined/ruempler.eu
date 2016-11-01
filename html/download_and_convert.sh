#!/bin/bash
blog_entries=$(curl www.ruempler.eu/blog | awk 'BEGIN{
RS="</a>"
IGNORECASE=1
}
{
  for(o=1;o<=NF;o++){
    if ( $o ~ /href/){
      gsub(/.*href=\042/,"",$o)
      gsub(/\042.*/,"",$o)
      print $(o)
    }
  }
}' - | sort | uniq | grep -P '^/\d{4}/' | grep -v 'commentsModule')

for entry in $blog_entries; do
    filename="${entry//\//-}".md
    filename="${filename/-/}"
    filename="${filename/-.md/.md}"
	curl www.ruempler.eu$entry > $filename 
done


while [ 1 ]; do
  jupyter notebook list | sed -E 's|http://[^:]*:|http://localhost:|; s|\s+::.*$||'
  sleep 4
done


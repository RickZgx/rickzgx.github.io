#/bin/bash

case "$1" in
  back)
    echo "back all posts to dropbox..."
    cp _posts/* /mnt/c/Users/zgx/Dropbox/blog
    ;;
  sync)
    echo "sync all posts to github..."
    cp /mnt/c/Users/zgx/Dropbox/blog/* _posts/
    ;;
  *)
    echo "Usage: bash build.sh {back|sync|...}"
    exit 1
    ;;
esac

exit 0
#Count all files recursively in a directory.
find ${1} -type d -exec sh -c "echo -n '{}' ' ' ; ls -1 '{}' | wc -l" \;

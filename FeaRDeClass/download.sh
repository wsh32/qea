if [ "$(ls -A download)" ]; then
    echo "Already downloaded"
else
    mkdir download
    wget https://github.com/chadwickbureau/baseballdatabank/archive/master.zip -O download/master.zip
    unzip download/master.zip -d download/
fi

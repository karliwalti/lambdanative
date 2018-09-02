echo "Building application..."
make
echo "Copying in configuration files to app directory"
cp -rf ~/tmp/PeruApp/* ~/.cache/lambdanative/linux/PeruApp

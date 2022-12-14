#/bin/sh
export MOUNT_DIR="/mnt/gcsfuse-mount"
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update
sudo apt-get install gcsfuse

sudo mkdir $MOUNT_DIR

sudo gcsfuse --implicit-dirs \
  $(gcloud compute instances describe $HOSTNAME --zone asia-east1-a --format='value[](metadata.items.mount_bucket_name)') \
  $MOUNT_DIR
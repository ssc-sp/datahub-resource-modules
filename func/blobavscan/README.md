# Note
This has been moved to https://github.com/fsdh-pfds/datahub-images/tree/main/managed-containers/clamav-blobavscan

# For testing
<pre>
docker build --platform linux/amd64 -t clamav-blobavscan .
docker tag clamav-blobavscan ghcr.io/ssc-sp/clamav-blobavscan
docker push ghcr.io/ssc-sp/clamav-blobavscan
</pre>
# Test Docker container
<pre>
docker build -t blobscan .
docker tag blobscan ghcr.io/ssc-sp/blobscan 
docker push ghcr.io/ssc-sp/blobscan   
# Change the image visibility to public
</pre>
# Test Docker container
<pre>
docker build -t blobavscan .
docker tag blobavscan ghcr.io/ssc-sp/blobavscan
docker push ghcr.io/ssc-sp/blobavscan   
# Change the image visibility to public
</pre>
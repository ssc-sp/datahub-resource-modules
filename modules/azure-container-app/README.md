# Deploy Docker Compose

For more details, see https://learn.microsoft.com/en-us/cli/azure/containerapp/compose?view=azure-cli-latest#az-containerapp-compose-create

For example:
<pre>
az containerapp compose create -g fsdh_proj_s2507j_dev_rg --environment fsdhprojs2507jdev-container-webapp-env --compose-file-path "./docker-compose.yml"
az containerapp ingress enable -n hello -g fsdh_proj_s2507j_dev_rg  --type external --allow-insecure --target-port 80 --transport auto
</pre>
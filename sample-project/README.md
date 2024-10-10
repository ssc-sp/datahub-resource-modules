# Test with sample project using templates

1. Copy template files: `./init.ps1 v4.0.0`
2. Init: `terraform init -backend-config="project.tfbackend"`
3. Validate: `terraform validate`
4. Apply: `terraform apply -auto-approve`
5. Destroy: `./destroy.ps1 -Force -NoPrompt`
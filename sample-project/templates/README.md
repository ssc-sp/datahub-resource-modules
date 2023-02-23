# Test with sample project using templates

1. Copy template files: `./sample-init.ps1`
2. Init: `terraform init -backend-config="project.tfbackend"`
3. Validate: `terraform validate`
4. Apply: `terraform apply -auto-approve`
5. Destroy: `./sample-destroy.ps -Force -NoPrompt`
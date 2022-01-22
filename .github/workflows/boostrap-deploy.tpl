name: "Execute Bootstrap Terraform Config"
on:
  push:
    branches: [ main ]
  paths:
    - 0-boostrap/*.tf*
    - 0-boostrap/modules/*.tf*

jobs:
  deploy-bootstrap:
    runs-on: ubuntu-latest
    steps:
    - id: checkout
      name: Checkout
      uses: actions/checkout@v2

    - id: 'auth'
      name: 'Authenticate to Google Cloud'
      uses: 'google-github-actions/auth@v0.4.0'
      with:
        token_format: 'access_token'
        workload_identity_provider: 'projects/PROJECT_ID/locations/global/workloadIdentityPools/POOL_NAME/providers/PROVIDER_NAME'
        service_account: 'SERVICE_ACCOUNT'

    - id:  'apply_bootstrap'
      name: 'Terraform Apply - Bootstrap'
      uses: docker://gcr.io/cloud-foundation-cicd/cft/developer-tools:1.0
      with:
        entrypoint: /bin/bash
        args: 'export GOOGLE_OAUTH_ACCESS_TOKEN=${{ steps.auth.outputs.access_token }} && terraform apply -var-file=bootstrap.tfvars -auto-approve'

name: "Execute Production Network Terraform Config"
on:
  push:
    branches: [main]
    paths:
      - 2-environments/production/network/*.tf
      - modules/shared_vpc/*.tf*
      - modules/hierachical_firewall_policy/*.tf*
      - .github/workflows/production-net-deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - id: checkout
        name: Checkout
        uses: actions/checkout@v2
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0.5.0'
        with:
          token_format: 'access_token'
          workload_identity_provider: WIF_PROVIDER_ID
          service_account: SERVICE_ACCOUNT
      - id: 'apply'
        name: 'Terraform Apply - Production Net'
        uses: docker://gcr.io/cloud-foundation-cicd/cft/developer-tools:1.0
        with:
          entrypoint: /bin/bash
          args: -c "export GOOGLE_OAUTH_ACCESS_TOKEN=${{ steps.auth.outputs.access_token }} && cd 2-environments/production/network && terraform init && terraform apply -auto-approve"

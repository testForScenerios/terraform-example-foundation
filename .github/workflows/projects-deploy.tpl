name: "Execute Project Factory Terraform"
on:
  push:
    branches: [main]
    paths:
      - 3-projects/*/*/*.tf
      - 3-projects/*/*/*.tfvars
      - helper/project-deploy-workflow.sh
      - modules/single_project/*.tf*
      - .github/workflows/projects-deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container: gcr.io/cloud-foundation-cicd/cft/developer-tools:1.0
    permissions:
      id-token: write
      contents: read
    steps:
      - id: checkout
        name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 2
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0.5.0'
        with:
          token_format: 'access_token'
          workload_identity_provider: WIF_PROVIDER_ID
          service_account: SERVICE_ACCOUNT
      - id: 'apply'
        name: 'Terraform Apply - Projects'
        run: |
          export GOOGLE_OAUTH_ACCESS_TOKEN=${{ steps.auth.outputs.access_token }}
          ./helper/project-deploy-workflow.sh
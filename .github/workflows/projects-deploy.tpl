name: "Execute Shared Services Network Terraform Config"
on:
  push:
    branches: [main]
    paths:
      - 3-projects/*/*.tf
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
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v0.5.0'
        with:
          token_format: 'access_token'
          workload_identity_provider: WIF_PROVIDER_ID
          service_account: SERVICE_ACCOUNT
      - id: 'Terraform Apply - Projects'
        run: |
          export GOOGLE_OAUTH_ACCESS_TOKEN=${{ steps.auth.outputs.access_token }}
          for file in $(git log -1 --pretty=format: --name-only --diff-filter=d | sort -u)
          do
            dir=$(dirname $file)
            cd $dir/
            terraform init
            terraform apply -auto-approve
          done
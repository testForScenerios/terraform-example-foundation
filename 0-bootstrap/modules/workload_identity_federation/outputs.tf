output "wif_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.wif_bootstrap.project_id
}

output "workload_identity_pool_name" {
  description = "Pool Name"
  value       = module.gh_oidc.pool_name
}

output "workload_identity_provider_name" {
  description = "Provider name"
  value       = module.gh_oidc.provider_name
}

output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for foundations pipelines in seed project."
  value       = module.seed_bootstrap.gcs_bucket_tfstate
}
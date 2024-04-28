
output "nestjs_repositories_url" {
  value = {
    for repo_url, repository_name in local.nestjs_repositories_name :
    repo_url => "${var.location}-docker.pkg.dev/${data.google_project.current.project_id}/${var.environment.prefix}-${data.google_project.current.name}-${repository_name}"
  }
  sensitive   = true
  description = "NestJS micro-services Artifact Registry repositories URL."
}

output "nestjs_repositories_name" {
  value       = {
    for repository_name in local.nestjs_repositories_name : 
    repository_name => {
    repository_name = "${var.environment.prefix}-${data.google_project.current.name}-${repository_name}"
    } 
  }
  sensitive   = false
  description = "NestJS micro-services Artifact Registry repositories name."
  depends_on  = [google_artifact_registry_repository.nestjs_repo]
}

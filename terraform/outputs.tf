output "server_ip" { value = aws_instance.k3s_server.public_ip }
output "github_repo" { value = github_repository.three_tier_app.html_url }
output "argocd_ui" {
  value = "http://${aws_instance.k3s_server.public_ip}:30080"
}

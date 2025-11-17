resource "null_resource" "configure_argocd_app" {
  depends_on = [aws_instance.k3s_server, github_repository.three_tier_app]

  provisioner "file" {
    content     = templatefile("${path.module}/argocd_application.tpl", { repo_url = github_repository.three_tier_app.html_url })
    destination = "/tmp/argocd-application.yaml"
  }

  connection {
    type        = "ssh"
    host        = aws_instance.k3s_server.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/argocd-application.yaml /opt/argocd-application.yaml",
      "sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl apply -f /opt/argocd-application.yaml"
    ]
  }
}

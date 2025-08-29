output "manager_ip" {
  value = aws_instance.swarm_manager.public_ip
}

output "worker_ips" {
  value = aws_instance.swarm_worker[*].public_ip
}
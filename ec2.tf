data "aws_ami" "ubuntu"{
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
        }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]

    }
    
resource "aws_instance" "ubuntu_ec2" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.medium"
    key_name = "key"
    vpc_security_group_ids = [aws_security_group.cluster_sg.id]
    tags = {
        Name = "manager"
    }

    


    provisioner "remote-exec" {
     inline = [
         "curl -fsSL https://get.docker.com -o get-docker.sh" ,
         "sudo sh get-docker.sh",
         "sudo docker swarm init",
         "sudo docker swarm join-token worker | grep SWMTKN > /home/ubuntu/tokenworker",
         
     ]
     connection {
         type = "ssh"
         port = 22
         user = "ubuntu"
         agent = false
         private_key = file(var.keypath)
         host = self.public_ip
         timeout = "1m"
     }
}

}

resource "aws_instance" "worker"{
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.medium"
    key_name = "key"
    vpc_security_group_ids = [aws_security_group.cluster_sg.id]

    tags = {
        Name = "worker"
    }

    provisioner "file" {
    source = "C:/Users/Junior/Downloads/atividade_avaliativa2/keys/key.pem"
    destination = "/home/ubuntu/key.pem"
    connection {
     type     = "ssh"
     user     = "ubuntu"
     host     = self.public_ip
     private_key = file(var.keypath)
  }
  }

     provisioner "remote-exec" {
     inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh" ,
      "sudo sh get-docker.sh",
      "sudo chmod 400 /home/ubuntu/key.pem",
      "sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/nullubuntu -i /home/ubuntu/key.pem ubuntu@${aws_instance.ubuntu_ec2.private_ip}:/home/ubuntu/tokenworker /home/ubuntu/tokenworker",
      "sudo $(cat /home/ubuntu/tokenworker)",
    ]
    connection {
     type     = "ssh"
     user     = "ubuntu"
     host     = self.public_ip
     private_key = file(var.keypath)
  }
  }
}
  resource "null_resource" "setup_docker_stack_services"{
    depends_on = [aws_instance.ubuntu_ec2, aws_instance.worker]
      connection {
          type = "ssh"
          user = "ubuntu"
          private_key = file(var.keypath)
          host = aws_instance.ubuntu_ec2.public_ip
      }
      provisioner "remote-exec" {
          inline = [
            "git clone https://github.com/christianochapouto/LAMP-stack-monitored-by-prometheus-grafana",
            "cd LAMP-stack-monitored-by-prometheus-grafana",
            "sudo docker stack deploy -c docker-compose.yml  LAMPstack",
            "cd monitoring",
            "sudo docker stack deploy -c docker-compose.yml monitoringstack",
    ]
  }
  }



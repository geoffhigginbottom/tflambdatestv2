resource "aws_security_group" "instance" {
  name = "Splunk-Open-Telemetry-Collector"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6501
    to_port     = 6501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "otc" {
  count                   = var.function_count
  ami                     = data.aws_ami.latest-ubuntu.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.instance.id]

#   user_data = <<-EOF
#             #!/bin/bash
#             sudo su
#             apt-get install \
#             apt-transport-https \
#             ca-certificates \
#             curl \
#             gnupg-agent \
#             software-properties-common -y
#             EOF

  tags = {
    Name  = "otc_${element(var.function_ids, count.index)}"
    Role  = "Open Telemetry Collector"
  }

  provisioner "file" {
    source      = "./scripts/install_smart_agent.sh"
    destination = "/tmp/install_smart_agent.sh"
  }

  provisioner "file" {
    source      = "./scripts/generate_signalfx_collector.sh"
    destination = "/tmp/generate_signalfx_collector.sh"
  }

  provisioner "file" {
    source      = "./scripts/generate_otc_startup.sh"
    destination = "/tmp/generate_otc_startup.sh"
  }


  provisioner "remote-exec" {
    inline = [
      ## Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
    
      ## Install SignalFx
      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "sudo chmod +x /tmp/install_smart_agent.sh",
      "sudo /tmp/install_smart_agent.sh $TOKEN $REALM $AGENTVERSION",
      # "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      # "sudo chown root:root /etc/signalfx/agent.yaml",
      # "sudo apt-mark hold signalfx-agent",
      # "sudo service signalfx-agent restart",

      ## Install shellinabox (used to enable shell access via browser)
      "sudo apt-get install shellinabox -y",
      "sudo sed -i 's/SHELLINABOX_PORT=4200/SHELLINABOX_PORT=6501/'  /etc/default/shellinabox",
      "sudo sed -i \"s/\"--no-beep\"/\"--no-beep --disable-ssl\"/\" /etc/default/shellinabox",
      "sudo service shellinabox restart",

      ## Install Docker
      "sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
      "sudo systemctl enable docker",

      # ## Write Vars to file (used for debugging)
      # "echo ${var.access_token} > /tmp/access_token",
      # "echo ${var.realm} > /tmp/realm",
      # "echo ${var.environmemt} > /tmp/environment",
      # "echo ${var.zpages_endpoint} > /tmp/zpages_endpoint",
      # "echo ${var.sfx_endpoint} > /tmp/sfx_endpoint",

      ## Set Vars for Collector
      "ZPAGES_ENDPOINT=${var.zpages_endpoint}",
      "ENVIRONMENT=${var.environmemt}",
      "SFX_ENDPOINT=${var.sfx_endpoint}",
      "COLLECTOR_YAML_PATH=${var.collector_yaml_path}",
      "COLLECTOR_NAME=${var.collector_docker_name}",
      "COLLECTOR_IMAGE=${var.collector_image}",

      # ## Write Vars to file (used for debugging)
      # "echo ${var.access_token} > /tmp/access_token",
      # "echo ${var.realm} > /tmp/realm",
      # "echo ${var.environmemt} > /tmp/environment",
      # "echo ${var.zpages_endpoint} > /tmp/zpages_endpoint",
      # "echo ${var.sfx_endpoint} > /tmp/sfx_endpoint",

      ## Generate signalfx-collector.yaml file
      "sudo chmod +x /tmp/generate_signalfx_collector.sh",
      "sudo /tmp/generate_signalfx_collector.sh $ZPAGES_ENDPOINT $ENVIRONMENT $TOKEN $SFX_ENDPOINT $REALM",

      ## Generate generate_otc_startup.sh file
      "sudo chmod +x /tmp/generate_otc_startup.sh",
      "sudo /tmp/generate_otc_startup.sh $COLLECTOR_YAML_PATH $COLLECTOR_NAME $COLLECTOR_IMAGE",

      ## Run collector
      "sudo chmod +x /tmp/otc-startup.sh",
      "sudo /tmp/otc-startup.sh",
    ]  
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    agent = "true"
  }
}


### The below wont work as its not trying to deploy onto the ec2 instance!!!
# Configure the Docker provider
# provider "docker" {
#   host = "tcp://127.0.0.1:2376/"
# }

# resource "docker_container" "otelcontribcol" {
#   image = "otel/opentelemetry-collector-contrib:0.14.0"
#   name = "otelcontribcol"
#   start = true
#   must_run = true
#   restart = "always"
#   memory = 683
#   mounts {
#     target = "/etc/collector.yaml"
#     type = "volume"
#     source = "/tmp/collector.yaml"
#     read_only = true
#   }
#   ports {
#     internal = "13133"
#     external = "13133"
#     }
#   ports {
#     internal = "55679"
#     external = "55679"
#   }
#   ports {
#     internal = "55680"
#     external = "55680"
#   }
#   ports {
#     internal = "660"
#     external = "660"
#     }
#   ports {
#     internal = "7276"
#     external = "7276"
#   }
#   ports {
#     internal = "8888"
#     external = "8888"
#   }
#   ports {
#     internal = "9411"
#     external = "9411"
#   }
#   ports {
#     internal = "9943"
#     external = "9943"
#   }    
# }

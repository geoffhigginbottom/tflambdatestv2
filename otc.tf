resource "aws_instance" "otc" {
  count                   = var.function_count
  ami                     = data.aws_ami.latest-ubuntu.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.splunk_otc.id]
  tags = {
    Name  = lower("${element(var.function_ids, count.index)}_otc")
    # Role  = "Open Telemetry Collector"
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

 provisioner "file" {
    source      = "./scripts/generate_update_sfx_environment.sh"
    destination = "/tmp/generate_update_sfx_environment.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
    
      # Install SignalFx
      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "sudo chmod +x /tmp/install_smart_agent.sh",
      "sudo /tmp/install_smart_agent.sh $TOKEN $REALM $AGENTVERSION",
      
      "sudo chmod +x /tmp/generate_update_sfx_environment.sh",
      "ENVIRONMENT=${var.environmemt}",
      "ENV_PREFIX=${element(var.function_ids, count.index)}",
      "sudo /tmp/generate_update_sfx_environment.sh $ENVIRONMENT $ENV_PREFIX",
      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "sudo /tmp/update_sfx_environment.sh",

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

      ## Set Vars for Collector
      # "ZPAGES_ENDPOINT=${var.zpages_endpoint}",
      # "COLLECTOR_ENDPOINT=${var.collector_endpoint}",
      "COLLECTOR_ENDPOINT=https://api.${var.realm}.signalfx.com",
      "ENVIRONMENT=${var.environmemt}",
      "SFX_ENDPOINT=https://ingest.${var.realm}.signalfx.com/v2/trace",
      
      "COLLECTOR_YAML_PATH=${var.collector_yaml_path}",
      "COLLECTOR_NAME=${var.collector_docker_name}",
      "COLLECTOR_IMAGE=${var.collector_image}",

      ## Write Vars to file (used for debugging)
      # "echo ${var.zpages_endpoint} > /tmp/zpages_endpoint",
      "echo ${var.access_token} > /tmp/access_token",
      "echo ${var.realm} > /tmp/realm",
      "echo ${var.environmemt} > /tmp/environment",
      # "echo ${var.sfx_endpoint} > /tmp/sfx_endpoint",
      "echo https://ingest.${var.realm}.signalfx.com/v2/trace > /tmp/sfx_endpoint",

      ## Generate signalfx-collector.yaml file
      "sudo chmod +x /tmp/generate_signalfx_collector.sh",
      "sudo /tmp/generate_signalfx_collector.sh $COLLECTOR_ENDPOINT $ENVIRONMENT $TOKEN $SFX_ENDPOINT $REALM",

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
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "OTC_Instances" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.otc.*.tags.Name,
    aws_instance.otc.*.public_ip,
  )
}
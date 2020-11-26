resource "aws_instance" "java_client" {
  count                   = var.function_count
  ami                     = data.aws_ami.latest-ubuntu.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.otc.id]
  tags = {
    Name  = "jc_${element(var.function_ids, count.index)}"
    Role  = "Open Telemetry Collector"
  }

  provisioner "file" {
    source      = "./scripts/install_smart_agent.sh"
    destination = "/tmp/install_smart_agent.sh"
  }

    provisioner "file" {
    source      = "./scripts/generate_java_app.sh"
    destination = "/tmp/generate_java_app.sh"
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
      # "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      # "sudo chown root:root /etc/signalfx/agent.yaml",
      # "sudo apt-mark hold signalfx-agent",
      # "sudo service signalfx-agent restart",

      ## Install shellinabox (used to enable shell access via browser)
      "sudo apt-get install shellinabox -y",
      "sudo sed -i 's/SHELLINABOX_PORT=4200/SHELLINABOX_PORT=6501/'  /etc/default/shellinabox",
      "sudo sed -i \"s/\"--no-beep\"/\"--no-beep --disable-ssl\"/\" /etc/default/shellinabox",
      "sudo service shellinabox restart",

      ## Write Vars to file (used for debugging)
      "echo ${var.access_token} > /tmp/access_token",
      "echo ${var.realm} > /tmp/realm",
            
      ## Install Maven 
      "sudo chmod +x /tmp/generate_java_app.sh",
      "JAVA_APP_URL=${var.java_app_url}",
      "INVOKE_URL=${aws_api_gateway_deployment.retailorder[count.index].invoke_url}",
      "sudo /tmp/generate_java_app.sh $JAVA_APP_URL $INVOKE_URL",
      "sudo chmod +x /tmp/java_app.sh",
      "sudo /tmp/java_app.sh",

      ## TO DO - auto run app / start as a service etc - TO DO ##
      ## mvn spring-boot:run
    ]  
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    # private_key = file("~/.ssh/id_rsa")
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

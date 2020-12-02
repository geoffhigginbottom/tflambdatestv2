resource "aws_instance" "java_client" {
  count                   = var.function_count
  ami                     = data.aws_ami.latest-ubuntu.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.splunk_jc.id]
  tags = {
    Name  = lower("${element(var.function_ids, count.index)}_jc")
    # Role  = "Open Telemetry Collector"
  }

  provisioner "file" {
    source      = "./scripts/install_smart_agent.sh"
    destination = "/tmp/install_smart_agent.sh"
  }

  provisioner "file" {
    source      = "./scripts/generate_java_app.sh"
    destination = "/tmp/generate_java_app.sh"
  }

  provisioner "file" {
    source      = "./scripts/generate_run_splunk_lambda_apm.sh"
    destination = "/tmp/generate_run_splunk_lambda_apm.sh"
  }

  provisioner "file" {
    source      = "./config_files/splunk_lambda_apm.service"
    destination = "/tmp/splunk_lambda_apm.service"
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

      ## Write Vars to file (used for debugging)
      "echo ${var.access_token} > /tmp/access_token",
      "echo ${var.realm} > /tmp/realm",
            
      ## Install Maven 
      "sudo chmod +x /tmp/generate_java_app.sh",
      "JAVA_APP_URL=${var.java_app_url}",
      "INVOKE_URL=${aws_api_gateway_deployment.retailorder[count.index].invoke_url}",
      "sudo /tmp/generate_java_app.sh $JAVA_APP_URL $INVOKE_URL",
      "sudo chmod +x /tmp/java_app.sh",
      "/tmp/java_app.sh",

      ## Set Java App to auto run
      # "APP_VERSION=${tostring(var.function_version_app_version)}",
      # "APP_VERSION=${var.function_version_app_version}",
      # "echo $APP_VERSION > /tmp/APP_VERSION", # debugging
      # "sudo chmod +x /tmp/generate_run_splunk_lambda_apm.sh",
      # "sudo /tmp/generate_run_splunk_lambda_apm.sh $APP_VERSION",
      # "sudo mv /tmp/run_splunk_lambda_apm.sh /usr/local/bin/run_splunk_lambda_apm.sh",
      # "sudo chown root:root /usr/local/bin/run_splunk_lambda_apm.sh",
      # "sudo chmod +x /usr/local/bin/run_splunk_lambda_apm.sh",
      # "sudo mv /tmp/splunk_lambda_apm.service /lib/systemd/system/splunk_lambda_apm.service",
      # "sudo chown root:root /lib/systemd/system/splunk_lambda_apm.service",
      # "sudo systemctl enable splunk_lambda_apm.service",
      # "sudo systemctl daemon-reload",
      # "sudo systemctl restart splunk_lambda_apm"
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

output "Java_Client_Instances" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.java_client.*.tags.Name,
    aws_instance.java_client.*.public_ip,
  )
}
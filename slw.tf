resource "aws_instance" "slw" {
  count                   = var.function_count
  ami                     = data.aws_ami.latest-ubuntu.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.splunk_lambda_workshop.id]
  user_data               = file("cloud-init/slw.yaml")
  tags = {
    Name  = lower("${element(var.function_ids, count.index)}_slw")
  }

  provisioner "file" {
    source      = "./scripts/install_smart_agent.sh"
    destination = "/tmp/install_smart_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_signalfx_config.sh"
    destination = "/tmp/update_signalfx_config.sh"
  }

  provisioner "file" {
    source      = "./config_files/collector.yaml"
    destination = "/tmp/collector.yaml"
  }

  provisioner "file" {
    source      = "./scripts/generate_otc_startup.sh"
    destination = "/tmp/generate_otc_startup.sh"
  }

 provisioner "file" {
    source      = "./scripts/update_sfx_environment.sh"
    destination = "/tmp/update_sfx_environment.sh"
  }

  provisioner "file" {
    source      = "./scripts/java_app.sh"
    destination = "/tmp/java_app.sh"
  }

  provisioner "file" {
    source      = "./scripts/run_splunk_lambda_apm.sh"
    destination = "/tmp/run_splunk_lambda_apm.sh"
  }

  provisioner "file" {
    source      = "./scripts/run_splunk_lambda_base.sh"
    destination = "/tmp/run_splunk_lambda_base.sh"
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
      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "ENVIRONMENT=${var.environment}",
      "ENV_PREFIX=${element(var.function_ids, count.index)}",
      "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT $ENV_PREFIX",
      "sudo chmod +x /tmp/update_signalfx_config.sh",
      "sudo /tmp/update_signalfx_config.sh",

    ## Write Vars to file (used for debugging)
      "echo ${var.access_token} > /tmp/access_token",
      "echo ${var.realm} > /tmp/realm",
      "echo ${var.environment} > /tmp/environment",
      "echo https://ingest.${var.realm}.signalfx.com/v2/trace > /tmp/sfx_endpoint",

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
      "TOKEN=${var.access_token}",
      "BALLAST=${var.ballast}",
      "REALM=${var.realm}",
      "OTELCOL_VERSION=${var.otelcol_version}",
      "ENVIRONMENT=${element(var.function_ids, count.index)}_${var.environment}",

    ## Move collector.yaml to /home/ubuntu and update permissions
      "sudo mv /tmp/collector.yaml /home/ubuntu/collector.yaml",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/collector.yaml",
      
    ## Generate collector startup script so users can easily restart it (it gets created in /home/ubuntu)
      "sudo chmod +x /tmp/generate_otc_startup.sh",
      "sudo /tmp/generate_otc_startup.sh $TOKEN $BALLAST $REALM $OTELCOL_VERSION $ENVIRONMENT",

    ## Run collector
      "sudo chmod +x /home/ubuntu/otc_startup.sh",
      "sudo chown ubuntu:ubuntu /home/ubuntu/otc_startup.sh",
      "/home/ubuntu/otc_startup.sh",

    ## Install Maven
      "JAVA_APP_URL=${var.java_app_url}",
      "INVOKE_URL=${aws_api_gateway_deployment.retailorder[count.index].invoke_url}",
      "sudo chmod +x /tmp/java_app.sh",
      "ENV_PREFIX=${element(var.function_ids, count.index)}",
      "sudo /tmp/java_app.sh $JAVA_APP_URL $INVOKE_URL $ENV_PREFIX",

    ## Install seige pre-reqs
      "sudo apt-get update",
      "sudo apt install looptools -y",
      "sudo apt install siege -y",

    ## Java App Helper Scripts
      "sudo chmod +x /tmp/run_splunk_lambda_apm.sh",
      "sudo chmod +x /tmp/run_splunk_lambda_base.sh",
      "sudo mv /tmp/run_splunk_lambda_apm.sh /home/ubuntu/run_splunk_lambda_apm.sh",
      "sudo mv /tmp/run_splunk_lambda_base.sh /home/ubuntu/run_splunk_lambda_base.sh",

    ## Set correct permissions on SplunkLambdaAPM directory
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/SplunkLambdaAPM",

    ## Configure motd
      "sudo curl -s https://raw.githubusercontent.com/signalfx/observability-workshop/master/cloud-init/motd -o /etc/motd",
      "sudo chmod -x /etc/update-motd.d/*",

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

output "SLW_Instances" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.slw.*.tags.Name,
    aws_instance.slw.*.public_ip,
  )
}
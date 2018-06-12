provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "gitlab-runner-os" {
  ami                    = "ami-820be4e5" //Core OS Stable AMI
  instance_type          = "t2.micro"
  key_name               = "keyname"
  vpc_security_group_ids = ["sg-1234567"]
  subnet_id              = "subnet-abcdef123"

  tags {
    Name = "gitlab-runner"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "core"
      private_key = "${file("keyname.pem")}"
    }

    inline = [
      "docker run -d -e DOCKER_IMAGE=docker:dind -e RUNNER_NAME=gitlab-runner -e CI_SERVER_URL=https://gitlab.com/ -e REGISTRATION_TOKEN=<insert-token-here> -e RUNNER_EXECUTOR=docker -e REGISTER_NON_INTERACTIVE=true --name gitlab-runner --restart always -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:alpine-v10.6.0",
      "docker exec -it gitlab-runner gitlab-runner register",
    ]
  }
}

provider "aws" {
  region = var.region
}

locals {
  pg_ip = "${aws_eip.my_static_ip.public_ip}"
}

resource "aws_instance" "instance_external" {
  cidr_block             = var.vpc_cidr_internal
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.external_cluster.id]
  key_name               = "${aws_key_pair.sergey.key_name}" // добавим ключ ansible host (либо скачать гит можно и так если он не приватный )

  provisioner "file" {
    source      = "~/Downloads/install.tar.gz" ///наш архив с ансиблом и прочим 
    destination = "/tmp/install.tar.gz"
  }

  ///ставим докер на хост 
  provisioner "remote-exec" {
    inline = [
      "sudo tar -zxvf /tmp/install.tar.gz ",
      "sudo /tmp/setup.sh deploy -t docker",
      "sudo apt-get install git -y",
      "sudo git clone git@github.com:uedemir/basic-django-and-postgresql-app.git",
      "sudo cd basic-django-and-postgresql-app/ ",
      "sudo sed -i 's/DATABASE_HOST=db/DATABASE_HOST=${local.pg_ip}/g' env/dev.env",
      "sudo docker-compose up -d --build",
      "sudo /tmp/setup.sh deploy -t nginx",
    ]
  }
}

resource "aws_instance" "instance_internal" {
  cidr_block             = var.vpc_cidr_internal
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.internal_cluster.id]
  key_name               = "${aws_key_pair.sergey.key_name}" // добавим ключ ansible host (либо скачать гит можно и так если он не приватный )
  provisioner "file" {
    source      = "~/Downloads/install.tar.gz" ///наш архив с ансиблом и прочим 
    destination = "/tmp/install.tar.gz"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo tar -zxvf /tmp/install.tar.gz ",
      "sudo /tmp/setup.sh deploy -t pg ",
      "echo ${self.public_dns}",
    ]
  }
}

//получаем ami последнего латтест образа убунты 
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

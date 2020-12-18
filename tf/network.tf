
data "aws_availability_zones" "working" {} //какие зоны сушествую в котором мы работаем 
data "aws_caller_identity" "current" {}    // aws account id полуить инфу по акк 
data "aws_vpcs" "my_vpcs" {}               //прочитает все наши виртуальные сети 


resource "aws_eip" "my_static_ip" {
  instance = aws_instance.instance_internal.id
  tags = {
    Name  = "Pg"
    Owner = "Ubuntu"
  }
}

locals {
  pg_ip = "${aws_eip.my_static_ip.public_ip}"
}

resource "aws_security_group" "external_cluster" {
  name        = "node_cluster group external "
  description = "node_cluster SecurityGroup"
  dynamic "ingress" {
    for_each = var.allow_ports_external
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  //куда угодно во вне внтри без ограничений 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "node_cluster SecurityGroup"
    Owner = var.owner
  }
}

//только внутри 
resource "aws_security_group" "internal_cluster" {
  name        = "node_cluster group internal "
  description = "node_cluster SecurityGroup"
  //принимаем входяший траффик на определенные порты из сети внутренней которую созлаи 
  dynamic "ingress" {
    for_each = var.allow_ports_internal
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_internal] ///откуда разрешаем доступ 
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_internal]
  }

  tags = {
    Name  = "pg_cluster SecurityGroup"
    Owner = var.owner
  }
}
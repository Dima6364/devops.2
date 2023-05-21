# Встановлення AWS-провайдера
provider "aws" {
  access_key = "YOUR_AWS_ACCESS_KEY"
  secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"
  region = "us-west-2"  # Замініть на бажану регіон AWS
}

# Створення VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Створення інтернет-шлюза та приєднання його до VPC
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

# Створення публічної підмережі та маршрутизації
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Створення Security Group
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 9100
    to_port     = 9100
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

# Створення першого EC2-сервера з встановленням Prometheus stack
resource "aws_instance" "prometheus_instance" {
  ami           = "ami-xxxxxxxx"  # Замініть на AMI ID відповідного регіону та образу
  instance_type = "t2.micro"  # Замініть на бажаний тип інстансу

  user_data = <<-EOF
    #!/bin/bash
    # В
# Створення другого EC2-сервера з встановленням Node-exporter
resource "aws_instance" "node_exporter_instance" {
  ami           = "ami-xxxxxxxx"  # Замініть на AMI ID відповідного регіону та образу
  instance_type = "t2.micro"  # Замініть на бажаний тип інстансу

  user_data = <<-EOF
    #!/bin/bash
    # Ваші команди для встановлення Node-exporter тут
  EOF

  # Приєднання до відповідної підмережі та Security Group
  subnet_id             = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  provisioner "remote-exec" {
    inline = [
      "echo 'Your Node-exporter installation commands here'"
    ]
  }
}

# Вивід публічних IP-адрес для доступу до EC2-серверів
output "prometheus_public_ip" {
  value = aws_instance.prometheus_instance.public_ip
}

output "node_exporter_public_ip" {
  value = aws_instance.node_exporter_instance.public_ip
}

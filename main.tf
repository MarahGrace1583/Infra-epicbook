provider "aws" {
  region = "us-east-1"
}

# ================= DEFAULT VPC =================
data "aws_vpc" "default" {
  default = true
}

# ================= DEFAULT SUBNET =================
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# ================= SECURITY GROUP =================
resource "aws_security_group" "epicbook_sg" {
  name        = "epicbook-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# ================= FRONTEND EC2 =================
resource "aws_instance" "frontend" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu (us-east-1)
  instance_type = "t2.micro"

  key_name = "devopskey"  # 👈 matches devopskey.pem

  subnet_id = tolist(data.aws_subnet_ids.default.ids)[0]

  vpc_security_group_ids = [aws_security_group.epicbook_sg.id]

  tags = {
    Name = "epicbook-frontend"
  }
}

# ================= BACKEND EC2 =================
resource "aws_instance" "backend" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  key_name = "devopskey"

  subnet_id = tolist(data.aws_subnet_ids.default.ids)[0]

  vpc_security_group_ids = [aws_security_group.epicbook_sg.id]

  tags = {
    Name = "epicbook-backend"
  }
}

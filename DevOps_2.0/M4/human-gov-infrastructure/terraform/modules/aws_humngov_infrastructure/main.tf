/*
resource "aws_security_group" "state_ec2_sg" {
  name        = "humangov-${var.state_name}-ec2-sg"
  description = "Allow traffic on ports 22 and 80"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["45.162.54.158/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["45.162.54.158/32"]
  }

  
    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["sg-0731b59bc276dec8f"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "humangov-${var.state_name}"
  }
}

resource "aws_instance" "state_ec2" {
  ami                      = "ami-007855ac798b5175e"
  instance_type            = "t2.micro"
  key_name                 = "jc-key-aws-us-east-1"
  vpc_security_group_ids   = [aws_security_group.state_ec2_sg.id]
  iam_instance_profile     = aws_iam_instance_profile.s3_dynamodb_full_access_instance_profile.name

  tags = {
    Name = "humangov-${var.state_name}"
  }

  provisioner "local-exec" {
	  command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
	}
	
	provisioner "local-exec" {
	  command = "echo ${var.state_name} id=${self.id} ansible_host=${self.private_ip} ansible_user=ubuntu us_state=${var.state_name} aws_region=${var.region} aws_s3_bucket=${aws_s3_bucket.state_s3.bucket} aws_dynamodb_table=${aws_dynamodb_table.state_dynamodb.name} >> /etc/ansible/hosts"
	}
	
	provisioner "local-exec" {
	  command = "sed -i '/${self.id}/d' /etc/ansible/hosts"
	  when = destroy
	}


}
*/

resource "aws_dynamodb_table" "state_dynamodb" {
  name         = "humangov-${var.state_name}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "humangov-${var.state_name}"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "state_s3" {
  bucket = "humangov-${var.state_name}-s3-${random_string.bucket_suffix.result}"
  acl    = "private"

  tags = {
    Name = "humangov-${var.state_name}"
  }
}


resource "aws_iam_role" "s3_dynamodb_full_access_role" {
  name = "humangov-${var.state_name}-s3_dynamodb_full_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
        Name = "humangov-${var.state_name}"
  }  
  
}

resource "aws_iam_role_policy_attachment" "s3_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"

}

resource "aws_iam_instance_profile" "s3_dynamodb_full_access_instance_profile" {
  name = "humangov-${var.state_name}-s3_dynamodb_full_access_instance_profile"
  role = aws_iam_role.s3_dynamodb_full_access_role.name

  tags = {
      Name = "humangov-${var.state_name}"
  }  
}
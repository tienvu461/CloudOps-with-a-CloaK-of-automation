data "aws_ami" "al2023_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"] #latest al2023 with x86_64 arch
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

data "cloudinit_config" "jumpbox_cloudinit" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/../../scripts/jumpbox_cloudinit.yaml")
  }
}

resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.al2023_latest.id
  availability_zone           = "${var.aws_region}a"
  ebs_optimized               = false
  instance_type               = "t3a.micro"
  monitoring                  = false
  key_name                    = "jumpbox"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  source_dest_check           = true
  iam_instance_profile        = aws_iam_instance_profile.jumpbox_role.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    tags                  = local.common_tags
  }

  user_data = data.cloudinit_config.jumpbox_cloudinit.rendered
  tags = {
    "Name"          = "${local.prefix}-jumpbox"
    "AUTO_DNS_ZONE" = "YOURZONEID"
    "AUTO_DNS_NAME" = "jumpbox.example.com"
  }
}

resource "aws_iam_instance_profile" "jumpbox_role" {
  name = "${local.prefix}-jumpbox-role"
  role = aws_iam_role.jumpbox_role.name
}

resource "aws_iam_role" "jumpbox_role" {
  name               = "${local.prefix}-jumpbox-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "jumpbox_policy" {
  name = "${local.prefix}-jumpbox-policy"
  role = aws_iam_role.jumpbox_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "ec2:DescribeTags",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "route53:ChangeResourceRecordSets",
        "Resource": "${data.aws_route53_zone.yourdns.arn}"
      }
    ]
}
POLICY
}

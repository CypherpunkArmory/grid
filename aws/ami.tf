data "aws_ami" "most_recent_cityworker_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["CITYWORKER AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "most_recent_city_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["CITY AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "most_recent_lb_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["LB AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "most_recent_tcplb_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["TCPLB AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "most_recent_dmz_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["DMZ AMI *"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "particular_city_ami" {
  filter {
    name = "name"
    values = ["CITY AMI *"]
  }

  filter {
    name = "tag:Version"
    values = ["${var.city_version}"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "particular_cityworker_ami" {
  filter {
    name = "name"
    values = ["CITYWORKER AMI *"]
  }

  filter {
    name = "tag:Version"
    values = ["${var.cityworker_version}"]
  }

  owners = ["578925084144"]
}



data "aws_ami" "particular_lb_ami" {
  filter {
    name = "name"
    values = ["LB AMI *"]
  }

  filter {
    name = "tag:Version"
    values = ["${var.lb_version}"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "particular_tcplb_ami" {
  filter {
    name = "name"
    values = ["TCPLB AMI *"]
  }

  filter {
    name = "tag:Version"
    values = ["${var.tcplb_version}"]
  }

  owners = ["578925084144"]
}

data "aws_ami" "particular_dmz_ami" {
  filter {
    name = "name"
    values = ["DMZ AMI *"]
  }

  filter {
    name = "tag:Version"
    values = ["${var.dmz_version}"]
  }

  owners = ["578925084144"]
}


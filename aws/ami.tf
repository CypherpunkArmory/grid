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
    values = ["${var.city_version == "most_recent" ? data.aws_ami.most_recent_city_ami.tags["Version"] : var.city_version}"]
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
    values = ["${var.cityworker_version == "most_recent" ? data.aws_ami.most_recent_cityworker_ami.tags["Version"] : var.cityworker_version}"]
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
    values = ["${var.lb_version == "most_recent" ? data.aws_ami.most_recent_lb_ami.tags["Version"] : var.lb_version}"]
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
    values = ["${var.dmz_version == "most_recent" ? data.aws_ami.most_recent_dmz_ami.tags["Version"] : var.dmz_version}"]
  }

  owners = ["578925084144"]
}


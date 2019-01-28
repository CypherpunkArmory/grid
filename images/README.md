# How to Spin up a Vagrant for Local Testing

## Basic Instructions

The default cookbook for the AMI produces an Virtualbox file that cannot be booted.

The only distinction is that that Amazon devices boot from `/dev/xvda` while
vbox files boot from `/dev/sda1`

In order to boot the box for local instructions, use `vagrant init` in the
images directory, then hold L-SHIFT in Virtualbox - as soon as you see the `boot:`
prompt type any characters to halt the boot process - you can then type

`local single`

and boot into single user mode locally.  You can then set up the device for
local access if you need something more.

## Creating an AMI from a locally built virtual-box.

You need `go-task` installed to build an AMI.
You will also need to install ansible locally.

See here: [go-task](https://github.com/go-task/task)

The primary task is `task ami`

You need to provide _at least_ a DISTRICT and A VER to build an AMI.

`task ami DISTRICT=city VER=0.0.9` will build CITY-0.0.9 AMI.  It will not tear down
infrastructure or boot those servers.  That's done through terraform.

Try `task --list` for more information.

## Advanced Instructions for booting ubunut-base.ova

If you have trouble booting the created images at all, these instruction
will let you use the serial console and advanced packaer commands to get really deep
into the weeds.

This directory includes the private key necessary to login to the server.

The provisioner will boot with packers local cloud-init to add this key to the
server, and removes the key before saving the final image.

If want to connect to the VM locally, you will need to boot the VM with a
cloud-init local `init.iso` attached.

The ISO already exists, but if you want to modify it, you can re-create it from
the meta-data files in `http`

```
cd http
mkisofs -output init.iso -volid cidata -joliet -rock {user-data,meta-data}
mv init.iso ..
```

The exported vagrant box will automatically attach this ISO file to provide a
local login.

You can then attach this ISO file to the import vagrant image to provide a local
login.

If you suspect trouble booting the "base" OVA file, you can add this stanza to
the `<x>_host.json` file and it will log all kernel boot output to a FIFO in the
build directory

```
"vboxmanage": [
        ["modifyvm", "{{.Name}}","--uart1", "0x3F8", "4", "--uartmode1", "server", "./Provision.ttyS0"]
]
```

Make sure to output to that console by adding `console=ttyS0 ` after `/vmlinuz`
in the boot command. (Note the trailing space!)

You can then view kernel boot output by executing `nc -U ./Provision.ttyS0`

Setting `headless` to `false` will also provid valuable output.

The `Vagrantfile.template` here is applied at the _machine_ level on your
workstation - so any overrides you place in the local `Vagrantfile` will take
precendence.




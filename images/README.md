# How to Spin up a Vagrant for Local Testing

## Basic Instructions

The default cookbook for the AMI produces an Virtualbox file that cannot be booted.

The only distinction is that that Amazon devices boot from `/dev/xvda` while
vbox files boot from `/dev/sda1` - you'll find a replacement command near the
end of the `city.yml` Ansible playbook that changes the boot stanza.  Removing
it will allow the device to boot in Virtualbox.

Note that it's not possible to create a device that's bootable in both
Virtualbox AND AWS at this time.

```
> packer build <x>_host.json
> vagrant init <x>_v<version>.box
> vagrant up
> vagrant ssh
```

## Advanced Instructions

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

## Creating an AMI from the Box

Once packer has created a `box` file you can turn this into an AMI with the
following steps.

1. Extract a VMDK from the Box file

```
tar xzvf city_v0.0.1.box
```

2. Upload the VMDK to AWS S3
```
aws s3 cp city-0.0.1-disk001.vmdk s3://city-amis
```

3. Import the snapshot to an EBS device
```
aws ec2 import-snapshot --description "City AMI $(date)" --disk-container file://containers.json
```

This will report a `snapshot-import-id` - you'll need that in the next step so
copy it from the out put

4. Wait for the import to be done.

```
watch "aws ec2 describe-import-snapshot-tasks | jq '.ImportSnapshotTasks[] | select(.ImportTaskId==\"import-snap-06e7c15732804c201\")'"
```

Replace "import-snap-1245deadbeef" with your import-snap job id.

5. Register that EBS volumas an ami

Replace the "snapshot-id" key in device-mapping.json with the snapshot id
reported in step 4.

```
aws ec2 register-image --name "City AMI 0.0.1" --virtualization-type "hvm" --root-device-name "/dev/xvda" --architecture "x86_64" --block-device-mappings file://device-mapping.json
```

6. Switch to grid / terraform plan / apply.





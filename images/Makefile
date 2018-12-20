city : city-build city-upload

city-build: ./city/tasks/* ./city/templates/* ./tasks/* ./city/city_host.json
	cd city && packer build -var 'version=$(ver)' -var 'template=city' city_host.json

city-upload:
	cd city && tar xzvf city_v$(ver).box
	cd city && aws s3 cp city-$(ver)-disk001.vmdk s3://city-amis
	cd city && ../imgwait city $(ver)

city-extract: ./city/city-$(ver)-disk001.vmdk
	cd city && tar xzvf city_v$(ver).box

city-clean-remote:
	$(eval AMI := $(shell aws ec2 describe-images --owners self --filter "Name=name,Values=CITY AMI $(ver)" | jq -r '.Images[].ImageId' ))
	aws ec2 deregister-image --image-id $(AMI)

lb : lb-build lb-upload

lb-build: ./lb/tasks/* ./lb/templates/* ./tasks/* ./lb/lb_host.json
	cd lb && packer build -var 'version=$(ver)' -var 'template=lb' lb_host.json

lb-upload: lb-build
	cd lb && tar xzvf lb_v$(ver).box
	cd lb && aws s3 cp lb-$(ver)-disk001.vmdk s3://city-amis
	cd lb && ../imgwait lb $(ver)

lb-clean-remote:
	$(eval AMI := $(shell aws ec2 describe-images --owners self --filter "Name=name,Values=LB AMI $(ver)" | jq -r '.Images[].ImageId' ))
	aws ec2 deregister-image --image-id $(AMI)

clean :
	cd city && yes | vagrant halt
	rm -rf ~/.vagrant.d/boxes/city*
	rm city/city*.box
	rm city/city*.vmdk
	rm city/metadata.json
	rm city/box.ovf
	rm city/Vagrantfile
	cd lb && yes | vagrant halt
	rm -rf ~/.vagrant.d/boxes/lb*
	rm lb/lb*.box
	rm lb/lb*.vmdk
	rm lb/metadata.json
	rm lb/box.ovf
	rm lb/Vagrantfile

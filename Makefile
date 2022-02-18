.PHONY: changelog release

SEMTAG=tools/semtag

CHANGELOG_FILE=CHANGELOG.md
TAG_QUERY=v11.0.0..
LSB_RELEASE=`lsb_release -cs`

scope ?= "minor"

echo:
	echo ${TEST}

install: install_terraform
	
install_terraform:
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl && \
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
	sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com ${LSB_RELEASE} main" && \
	sudo apt-get update && sudo apt-get install -y terraform

## WIP: NOT READY YET
install_precommit:
	sudo apt update
	sudo apt install -y unzip software-properties-common python3 python3-pip
	python3 -m pip install --upgrade pip
	pip3 install --no-cache-dir pre-commit
	pip3 install --no-cache-dir checkov
	curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
	curl -L "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
	curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
	curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
	sudo apt install -y jq && \
	curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register

precommit:
	pre-commit run -a

changelog-unrelease:
	git-chglog --no-case -o $(CHANGELOG_FILE) $(TAG_QUERY)

changelog:
	git-chglog --no-case -o $(CHANGELOG_FILE) --next-tag `$(SEMTAG) final -s $(scope) -o -f` $(TAG_QUERY)

release:
	$(SEMTAG) final -s $(scope)

costing:
	infracost breakdown --path $(pwd) --usage-file .infracost-usage.yml
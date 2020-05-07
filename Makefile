.PHONY: all destroy-all destroy-backend set-env bake-node bake-bastion prep-vpc init-vpc create-vpc destroy-vpc init output plan-destroy plan prep
.SHELL := $(shell which bash)
CURRENT_FOLDER=$(shell basename "$$(pwd)")
S3_BUCKET="$(ENV)-$(REGION)-devops-tfstate"
DYNAMODB_TABLE="$(ENV)-$(REGION)-devops-locking"
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)
terraform:= $(shell command -v terraform 2> /dev/null)
aws:=$(shell command -v aws 2> /dev/null)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(ENV) ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ -z $(REGION) ]; then \
		echo "$(BOLD)$(RED)REGION was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`ENV=dev REGION=ap-southeast-1 make plan\`$(RESET)"; \
		exit 1; \
	 fi

bake-node: ## Build Node AMI
	figlet "Bake Node AMI"
	@packer build -var 'region=$(REGION)' -var 'environment=$(ENV)' packer/ec2-node.json 

bake-bastion: ## Build Bastion AMI
	figlet "Bake Bastion AMI"
	@packer build -var 'region=$(REGION)' -var 'environment=$(ENV)' packer/ec2-bastion.json

prep: set-env ## Prepare S3 and DynamoDB to store Terraform backend state.
	figlet "Prepare State File"
	@rm -rf ./.terraform tf.output
	@bash one_time_setup.sh prep $(REGION) $(ENV) $(S3_BUCKET) $(DYNAMODB_TABLE)
	@echo "$(BOLD)$(GREEN)S3 bucket $(S3_BUCKET) created$(RESET)"
	@echo "$(BOLD)$(GREEN)DynamoDB table $(DYNAMODB_TABLE) created$(RESET)";

prep-vpc: set-env ## Prepare S3 and DynamoDB to store Terraform backend state.
	figlet "Prepare State File"
	@rm -rf ./.terraform tf.output
	@bash one_time_setup.sh prep-vpc $(REGION) $(ENV) $(S3_BUCKET) $(DYNAMODB_TABLE)
	@echo "$(BOLD)$(GREEN)S3 bucket $(S3_BUCKET) created$(RESET)"
	@echo "$(BOLD)$(GREEN)DynamoDB table $(DYNAMODB_TABLE) created$(RESET)";

init-vpc: prep-vpc ## Initiate module and backend state.
	figlet "Prepare Backend"
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@terraform init \
				-input=false \
				-force-copy \
				-lock=true \
				-var "aws_region=$(REGION)" \
                -var "aws_environment=$(ENV)" \
				terraform/infrastructure/$(ENV)

create-vpc: init-vpc ## Create VPC
	figlet "Create VPC"
	@if [ $(ENV) = "dev" ]; then \
		$(terraform) apply \
				-lock=true \
				-input=false \
				-refresh=true \
				-var "aws_region=$(REGION)" \
                -var "aws_environment=$(ENV)" \
				-auto-approve \
				terraform/infrastructure/$(ENV); \
	fi

deploy-infra: init ## Have Terraform do the things. This will cose money
	figlet "Deploy Infra"
	@if [ $(ENV) = "dev" ]; then \
		$(terraform) apply \
					-lock=true \
					-input=false \
					-refresh=true \
					-auto-approve \
					-var "aws_region=$(REGION)" \
                    -var "aws_environment=$(ENV)" \
					terraform/environment/$(ENV); \
	fi

destroy-vpc: init-vpc ## Create VPC
	figlet "Destroy VPC"
	@if [ $(ENV) = "dev" ]; then \
		$(terraform) destroy \
				-lock=true \
				-input=false \
				-refresh=true \
				-var "aws_region=$(REGION)" \
                -var "aws_environment=$(ENV)" \
				-auto-approve \
				terraform/infrastructure/$(ENV); \
	fi

destroy-infra: init
	figlet "Destroy Infra"
	@if [ $(ENV) = "dev" ]; then \
		$(terraform) destroy \
					-lock=true \
					-input=false \
					-refresh=true \
					-var "aws_region=$(REGION)" \
                    -var "aws_environment=$(ENV)" \
					-auto-approve \
					terraform/environment/$(ENV); \
	fi

init: prep ## Initiate module and backend state.
	figlet "Prepare Backend"
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@terraform init \
				-input=false \
				-force-copy \
				-lock=true \
				terraform/environment/$(ENV)

plan: init ## Show what terraform thinks it will do
	@terraform plan \
				-lock=true \
				-input=false \
				-refresh=true \
				-var "aws_region=$(REGION)" \
                -var "aws_environment=$(ENV)" \
				terraform/environment/$(ENV)

plan-destroy: init ## Creates a destruction plan.
	@terraform plan \
				-input=false \
				-refresh=true \
				-var "aws_region=$(REGION)" \
                -var "aws_environment=$(ENV)" \
				-destroy \
				terraform/environment/$(ENV)

destroy-backend: ## Destroy S3 bucket and DynamoDB table and clean up the local state.
	figlet "Destroy Dynamic State"
	@bash one_time_setup.sh destroy $(REGION) $(ENV) $(S3_BUCKET) $(DYNAMODB_TABLE)
	@echo "Clean up the terraform local state"
	@rm -rf ./.terraform tf.output

all: create-vpc deploy-infra ## Bring up all the environment and Deploy Application Cluster

destroy-all: destroy-infra destroy-vpc destroy-backend ## Destroy all environment and terraform backend state

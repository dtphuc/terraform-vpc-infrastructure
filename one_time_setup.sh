#!/bin/bash
function prep(){

  

  echo 
  echo "########################################"
  echo "Bucket: ${S3_BUCKET}; Region: ${REGION}"
  echo "########################################"

  echo "Verifying that the S3 bucket ${S3_BUCKET} for remote state exists"

  
  if ! aws s3 ls ${S3_BUCKET} > /dev/null 2>&1 ; then
    echo "S3 bucket was not found, creating new bucket with versioning enabled to store tfstate"
    aws s3api create-bucket \
      --bucket ${S3_BUCKET} \
      --acl private \
      --region ${REGION} \
      --create-bucket-configuration LocationConstraint=${REGION}
    aws s3api put-bucket-versioning \
      --bucket ${S3_BUCKET} \
      --versioning-configuration Status=Enabled
    echo "S3 bucket ${S3_BUCKET} created"
  else
    echo "S3 bucket ${S3_BUCKET} exists"
  fi 

  echo 
  echo "Verifying that the DynamoDB table exists for remote state locking"
  echo 
  if ! aws dynamodb describe-table --region ${REGION} --table-name ${DYNAMODB_TABLE} > /dev/null 2>&1 ; then
    echo "DynamoDB table ${DYNAMODB_TABLE} was not found, creating new DynamoDB table to maintain locks"
    aws dynamodb create-table \
        --region ${REGION} \
        --table-name ${DYNAMODB_TABLE} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
      echo "DynamoDB table ${DYNAMODB_TABLE} created"
      echo "Sleeping for 10 seconds to allow DynamoDB state to propagate through AWS"
      sleep 10;
    
  else
    echo "DynamoDB Table ${DYNAMODB_TABLE} exists"
  fi

  if test -f terraform/environment/${ENV}/backend.tf ; then
    cat <<EOF > terraform/environment/${ENV}/backend.tf
terraform {
    backend "s3" {
      bucket         = "${S3_BUCKET}"
      key            = "${ENV}/${ENV}-devops-practice.tfstate"
      region         = "${REGION}"
      encrypt        = "true"
      dynamodb_table = "${DYNAMODB_TABLE}"
    }
}
EOF
  fi

}

function prep-vpc(){

  echo 
  echo "########################################"
  echo "Bucket: ${S3_BUCKET}; Region: ${REGION}"
  echo "########################################"

  echo "Verifying that the S3 bucket ${S3_BUCKET} for remote state exists"

  
  if ! aws s3 ls ${S3_BUCKET} > /dev/null 2>&1 ; then
    echo "S3 bucket was not found, creating new bucket with versioning enabled to store tfstate"
    aws s3api create-bucket \
      --bucket ${S3_BUCKET} \
      --acl private \
      --region ${REGION} \
      --create-bucket-configuration LocationConstraint=${REGION}
    aws s3api put-bucket-versioning \
      --bucket ${S3_BUCKET} \
      --versioning-configuration Status=Enabled
    echo "S3 bucket ${S3_BUCKET} created"
  else
    echo "S3 bucket ${S3_BUCKET} exists"
  fi 

  echo 
  echo "Verifying that the DynamoDB table exists for remote state locking"
  echo 
  if ! aws dynamodb describe-table --region ${REGION} --table-name ${DYNAMODB_TABLE} > /dev/null 2>&1 ; then
    echo "DynamoDB table ${DYNAMODB_TABLE} was not found, creating new DynamoDB table to maintain locks"
    aws dynamodb create-table \
        --region ${REGION} \
        --table-name ${DYNAMODB_TABLE} \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
      echo "DynamoDB table ${DYNAMODB_TABLE} created"
      echo "Sleeping for 10 seconds to allow DynamoDB state to propagate through AWS"
      sleep 10;
    
  else
    echo "DynamoDB Table ${DYNAMODB_TABLE} exists"
  fi

  echo "Creating Backend State file.."

  if test -f terraform/infrastructure/${ENV}/backend.tf ; then
    cat <<EOF > terraform/infrastructure/${ENV}/backend.tf
terraform {
    backend "s3" {
      bucket         = "${S3_BUCKET}"
      key            = "${ENV}/${ENV}_vpc.tfstate"
      region         = "${REGION}"
      encrypt        = "true"
      dynamodb_table = "${DYNAMODB_TABLE}"
    }
}
EOF
  fi

  echo "Done creating backend state file.."

  echo "Creating Backend Data VPC State."
  if test -f terraform/environment/${ENV}/data_vpc.tf; then
    cat <<EOF > terraform/environment/${ENV}/data_vpc.tf
data "terraform_remote_state" "${ENV}_vpc" {
  backend = "s3"
  config = {
    bucket         = "${S3_BUCKET}"
    key            = "${ENV}/${ENV}_vpc.tfstate"
    region         = "${REGION}"
    encrypt        = "true"
  }
}
EOF
  fi

  echo "Done Creating Backend Data VPC State."
}

function destroy(){
  echo 
  echo "Deleting DynamoDB...."
  if ! aws dynamodb delete-table --region ${REGION} --table-name ${DYNAMODB_TABLE} > /dev/null 2>&1 ; then \
		echo "Unable to delete DynamoDB table or Table does not exist.."
	else
		echo "DynamoDB table ${DYNAMODB_TABLE} is deleting."; \
	fi

  echo "Trying to delete S3 bucket/objects.."
  
  if ! aws s3api delete-objects \
      --region ${REGION} \
      --bucket ${S3_BUCKET} \
      --delete "$(aws s3api list-object-versions \
						        --region ${REGION} \
						        --bucket ${S3_BUCKET} \
                    --output=json \
						        --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" > /dev/null 2>&1; then

		echo "Unable to delete objects in S3 bucket ${S3_BUCKET}"
	fi
	
  aws s3api delete-bucket --region ${REGION} --bucket ${S3_BUCKET}
	if [ "$?" != 0 ]; then
  	echo "Unable to delete S3 bucket ${S3_BUCKET}"
	fi

  echo "Successfully destroy ${S3_BUCKET} and ${DYNAMODB_TABLE}"
}

OPTION=$1
REGION=$2
ENV=$3
S3_BUCKET=$4
DYNAMODB_TABLE=$5

function check_params(){
  if [ -z "$OPTION" ] || [ -z "$REGION" ] || [ -z "$ENV" ] || [ -z "${S3_BUCKET}" ] || [ -z "${DYNAMODB_TABLE}" ]; then
    echo "The environment variables has not been setup!!!"
    exit 1
  fi
}

figlet "S3 State Bucket Setup"

case $1 in
  prep)
    echo -n "Preparing Terraform Backend State.."
    check_params
    prep
    ;;
  prep-vpc)
    echo -n "Preparing Terraform Backend State.."
    check_params
    prep-vpc
    ;;
  destroy)
    echo -n "Destroying Terraform Backend State.. Please be careful you can lost your infrastructure..!!"
    check_params
    destroy
    ;;
  deploy)
    echo -n "Preparing for deploying app..."
    deploy_app
    ;;
  *)
    echo -n "Unknow option.!!"
    ;;
esac
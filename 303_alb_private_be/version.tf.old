/*---------------------------------------------------------------------------------------
© 2022 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
 
This AWS Content is provided subject to the terms of the AWS Customer Agreement
available at http://aws.amazon.com/agreement or other written agreement between
Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.
---------------------------------------------------------------------------------------*/

#currently Terraform has not support ap-southeast-3
# Issue: https://github.com/hashicorp/terraform-provider-aws/issues/22252

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"

      version = ">= 3.5.0, != 3.14.0, >= 5.36.0"
    }
    # template = {
    #   source = "hashicorp/template"
    # }
    # time = {
    #   source = "hashicorp/time"
    # }
  }

  backend "s3" {
    # Replace this with your bucket name!
    bucket                 = "his-preprod-terraform-state" #"<Your Bucket Name>"
    key                    = "terraform-states/his-preprod-terraform-state/kairos/303_alb_private_fe/terraform.tfstate"
    region                 = "ap-southeast-3" #"<Your Region>"
    skip_region_validation = true

    # Replace this with your DynamoDB table name!
    dynamodb_table = "siloam-preprod-terraform-state" #"<Your Dynamo DB>"
    encrypt        = true
  }

  required_version = ">= 1.0"
}


# Configure the AWS Provider
provider "aws" {
  region                 = var.region #"<Your Region>" 

  skip_region_validation = true
  default_tags {
    # tags = var.tags
    tags = {
      Managed_Via = "TerraformManaged"
      Environment = var.environment
      # Owner           = var.application_name
      # map-migrated = "mig40404"

      OwnerTeam          = "Kairos"
      DepartmentID       = "Kairos"
      DataClassification = "clinical" # set for clinical for now. will need Siloam team to set which one use clinical / non clinical
      ManagedVia         = "Terraform"
      ProvisionedBy      = "Triy_ITSP"
      map-migrated       = "migXE6ORY1HAF"
      Purpose            = "network"
    }
  }
}



data "aws_caller_identity" "current" {}

locals {
  # Account id
  account_id = data.aws_caller_identity.current.account_id

}
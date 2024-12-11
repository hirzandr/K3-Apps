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
}

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

      OwnerTeam          = "k3"
      DepartmentID       = "k3"
      DataClassification = "non-clinical" # set for clinical for now. will need Siloam team to set which one use clinical / non clinical
      ManagedVia         = "Terraform"
      ProvisionedBy      = "Hirzan-SSE"
      map-migrated       = "migXE6ORY1HAF"
      Purpose            = "app-container"
    }
  }
}
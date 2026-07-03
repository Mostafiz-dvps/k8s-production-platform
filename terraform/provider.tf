terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote backend stored in a pre-existing Azure Storage Account.
  # This enables team collaboration because everyone reads/writes the same state,
  # and state locking prevents concurrent, conflicting terraform apply operations.
  backend "azurerm" {
    # Name of the pre-existing resource group that contains the Terraform state storage account.
    resource_group_name = "REPLACE_WITH_TFSTATE_RESOURCE_GROUP"

    # Name of the pre-existing Azure Storage Account used to store Terraform state.
    storage_account_name = "REPLACE_WITH_TFSTATE_STORAGE_ACCOUNT"

    # Name of the pre-existing blob container inside the storage account for state files.
    container_name = "REPLACE_WITH_TFSTATE_CONTAINER"

    # Blob name/path for this environment's state file.
    key = "REPLACE_WITH_ENVIRONMENT.tfstate"
  }
}

provider "azurerm" {
  features {}
}

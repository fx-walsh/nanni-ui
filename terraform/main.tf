terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0" # Locking down to the stable v5 release line
    }
  }

  backend "s3" {
    bucket                      = "nanni-tf-state-bucket"
    key                         = "landing-page/terraform.tfstate"
    endpoints = {
      s3 = "https://6e4797ab8d86f38cf9fafb24903cfab3.r2.cloudflarestorage.com"
    }
    region                      = "auto"                      # CRITICAL: Cloudflare R2 maps best to "auto"
    skip_credentials_validation = true                        # Skips AWS-specific STS verification
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true                        # CRITICAL: Forces path-style endpoint structuring
  }
}

provider "cloudflare" {
  # Automatically picks up CLOUDFLARE_API_TOKEN environment variable
}

# Dynamic Variables
variable "account_id" {
  type        = string
  description = "Your Cloudflare Account ID"
}

variable "environment" {
  type        = string
  description = "The target deployment environment (dev or prod)"
}

variable "github_repo" {
  type    = string
  default = "yourusername/nanni-landing-page"
}

resource "cloudflare_pages_project" "nanni_landing" {
  account_id = var.account_id
  # Results in 'nanni-landing-page-dev' or 'nanni-landing-page-prod'
  name              = "nanni-landing-page-${var.environment}"
  production_branch = var.environment == "prod" ? "master" : "dev"

  source {
    type = "github"
    config {
      owner               = split("/", var.github_repo)[0]
      repo_name           = split("/", var.github_repo)[1]
      production_branch   = var.environment == "prod" ? "master" : "dev"
      deployments_enabled = true
      pr_comments_enabled = true
    }
  }

  build_config {
    build_command   = ""
    destination_dir = ""
    root_dir        = ""
  }

  deployment_configs {
    preview {
      environment_variables = {
        ENVIRONMENT = var.environment
      }
    }
    production {
      environment_variables = {
        ENVIRONMENT = var.environment
      }
    }
  }
}
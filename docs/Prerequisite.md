# Prerequisites

## Cloud Resources
AWS:
- pre-created AWS account
- IAM profile/role with provisioner access
- (Optional) keypair to manage nodes - just to ease the file prep process, can actually do this via SSM without keypair
- (Optional) pre-created s3 bucket to accommodate remote Terraform backend state - can do local

## Core Utilities
- AWSCLIv2
- Terraform
- openssh

## MISC Utilities
- jq
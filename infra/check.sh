#!/usr/bin/env bash
terraform fmt
tflint -f compact
terraform validate

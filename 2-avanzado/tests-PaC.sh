#!/bin/bash

terraform plan -out terraform.tfplan && python test-policy-as-code.py

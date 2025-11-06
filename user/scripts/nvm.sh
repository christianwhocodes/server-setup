#!/bin/bash
set -e
# https://github.com/nvm-sh/nvm

# Use environment variable or default to v0.40.3
NVM_VERSION="${NVM_VERSION:-v0.40.3}"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

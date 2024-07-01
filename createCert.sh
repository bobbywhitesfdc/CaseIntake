#!/bin/bash
# Exit on error!
set -euxo pipefail

# Install the CI Plugin
sfdx plugins:install @assisisolutions/sfdx-ci-plugin

# Create the Cert and the Connected App
sfdx ci:setup  --name "TelephonyApp" --permissionsetname "AdminAccess"
sf org assign permset --name AdminAccess -o CaseModel


#sfdx ci:setup --targetusername myOrg@example.com --certfile mycert.pem

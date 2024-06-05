#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}
#create scratch org
# let it auto-assign the username ( username="$(prop 'user.admin' )" )
sfdx force:org:create -f config/project-scratch-def.json -s -a CASEMODEL  --durationdays 28
sfdx force:source:push

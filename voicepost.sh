#!/bin/bash
# Exit on error!
set -euxo pipefail

# use SFDX CLI to get the auth token and instance URL
orgJson=(sf org display -o CASEMODEL --json)

# Generate a specific JWT for the Telephony Endpoints
jwtValue=$(java -jar ../JWTUtil/target/JWTUtil-1.0-jar-with-dependencies.jar)

#hard code these temporarily
#jwtValue='eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiAiM01WRzlBWXVnTXdHQWhZNFhOQzZyZmdlTjlxZlFYOENKOWIya2ZBNWpvMFNuVzZ2QU01ZEVHcER0eVRZb3k0Q2FyQ1BjWEFIdWFhRUlGeldFQ1FUdiIsICJzdWIiOiAidGVzdC04MXlyaHZiY3NreWFAZXhhbXBsZS5jb20iLCAiYXVkIjogImh0dHBzOi8vc2NydC5zYWxlc2ZvcmNlLmNvbSIsICJleHAiOiAiMTcxNzg5NTE4NiJ9.mtajVpwd2FPjkfcTY6UcxgxKEHZzBcEGfJYJwSM4FDJfnpkef6BaMjR4EKTJOrDu2v2kQmwHh_66HZVpTWNLXprwvY5LUCe5czlo7fI34KuacXn_1C6IWz9x2WkHpZpDK1lvMxF9kSOfY_Az8FOdJtIFY0kj1UG85eesRSsflMjvy4JRoZytt5Zj34NjxUBC1llKCHOBg1FfzZ4hzZjHZs21XeJf56Rl1T0NNo0_fV0s_SjS1981Lf5LBrvUsYA65LQ1-LcFlx0jIH0pVihNcTBm5rwSk2t585D2qyYBCwfB7bZqPeHZieCYQdaP5xp0_XMavc3OhWThatED8HFhWQ'
instanceUrl='https://saas-saas-9574-dev-ed.scratch.my.salesforce-scrt.com'
telephonyResource='/telephony/v1/voiceCalls'
destURL=$instanceUrl$telephonyResource

curl -X POST $destURL -H "Content-Type: application/json" -H "Authorization: Bearer $jwtValue"  -d @request.json  -w "%{http_code}\\n" -o response.json
#curl -X POST $destURL -H "Content-Type: application/json" -d @request.json  -w "%{http_code}\\n" -o response.json
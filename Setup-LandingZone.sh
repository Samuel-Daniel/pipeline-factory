#!/bin/zsh

ProducteName="iti"
FeatureName="onboarding"

# Product Accounts
DevToolsAccount="935187548418"
DevAccount="255538382414"
HomologAccount="450454659259"
ProdAccount="754190108602"

#Shared Account
DevOpsAccount="300003219274"
ArchitectureAccount="000000000000"


# Create CrossAccount Roles
aws cloudformation deploy --stack-name RoleCrossAccount --template-file General/SetupCrossAccount.yaml --capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides DevToolsAccount=$DevToolsAccount --profile DevAccount \
&
aws cloudformation deploy --stack-name RoleCrossAccount --template-file General/SetupCrossAccount.yaml --capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides DevToolsAccount=$DevToolsAccount --profile HomologAccount \
&
aws cloudformation deploy --stack-name RoleCrossAccount --template-file General/SetupCrossAccount.yaml --capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides DevToolsAccount=$DevToolsAccount --profile ProdAccount \
&
aws cloudformation deploy --stack-name RoleCrossAccount --template-file General/SetupCrossAccount.yaml --capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides DevToolsAccount=$DevToolsAccount --profile DevOpsAccount \
&
aws cloudformation deploy --stack-name Networking --template-file General/Setup-Networking.yaml --capabilities CAPABILITY_NAMED_IAM --profile DevAccount \
&
aws cloudformation deploy --stack-name Networking --template-file General/Setup-Networking.yaml --capabilities CAPABILITY_NAMED_IAM --profile HomologAccount \
&
aws cloudformation deploy --stack-name Networking --template-file General/Setup-Networking.yaml --capabilities CAPABILITY_NAMED_IAM --profile ProdAccount \
&
aws cloudformation deploy --stack-name Setup-DevTools  --template-file DevTools/Setup-DevTools.yaml --capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides DevOpsAccount=$DevOpsAccount DevAccount=$DevAccount HomologAccount=$HomologAccount ProdAccount=$ProdAccount \
--profile DevToolsAccount
# Create StackBase @ DevTools Account


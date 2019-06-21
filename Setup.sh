#!/bin/sh

# Template
Template="microservice-001"

# Contas - BUENOH
#DevToolsAccount="935187548418"
#DevAccount="255538382414"
#HomologAccount="450454659259"
#ProdAccount="754190108602"
#DevOpsAccount="300003219274"
#ArchitectureAccount="000000000000"
#ProfileDevToolsAccount="DevToolsAccount"
#ProfileDevAccount="DevAccount"
#ProfileHomologAccount="HomologAccount"
#ProfileProdAccount="ProdAccount"
#ProfileDevOpsAccount="DevOpsAccount"
#ProfileArchitectureAccount="ArchitectureAccount"

# Contas - LZ LAB 
DevToolsAccount="341071025030"
DevAccount="141748752792"
HomologAccount="111725924533"
ProdAccount="688517861080"
DevOpsAccount="863884412775"
ArchitectureAccount="000000000000"
ProfileDevToolsAccount="Lab-DevTools"
ProfileDevAccount="Lab-Dev"
ProfileHomologAccount="Lab-Homolog"
ProfileProdAccount="Lab-Prod"
ProfileDevOpsAccount="Lab-DevOps"
ProfileArchitectureAccount="Lab-ArchitectureAccount"


########################################
# Relação de Stacks que serão criadas
#
#   DevOps
#       SharedLibs
#       CrossAccountRoleSharedLibs
#
#   DevTools
#       Setup-DevTools
#
#   Dev/Homolog/Prod   
#       CrossAccountRole
#
########################################


######################################## Cria Stack na conta DevOpsAccount
#   - Repositorio sharedlibs
#   - Bucket sharedlibs
echo Creating Stack SharedLibs @ DevOpsAccount - $DevOpsAccount using $ProfileDevOpsAccount profile
aws cloudformation deploy --stack-name SharedLibs --template-file DevSecOps-Account/DevOps-SharedLibs.yaml \
--parameter-overrides DevToolsAccount=$DevToolsAccount DevAccount=$DevAccount HomologAccount=$HomologAccount ProdAccount=$ProdAccount \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileDevOpsAccount 

aws cloudformation wait stack-create-complete --stack-name SharedLibs --profile $ProfileDevOpsAccount 

##### Variavel criadas após execução do DevTools-Setup
## TemplateURL
TemplateURL=$(aws cloudformation describe-stacks --stack-name SharedLibs --query 'Stacks[0].Outputs[?OutputKey==`TemplateBucket`].OutputValue' --output text --profile $ProfileDevOpsAccount)
echo TemplateURL: $TemplateURL.yaml

# Copia template para o bucket. Esse template será usado pela Lambda CriaFeaturePipeline
aws s3 cp $Template.yaml s3://$TemplateURL/ --profile $ProfileDevOpsAccount
echo URL do template: s3://$TemplateURL/$Template.yaml


######################################## Setup-DevTools
# - Conta: DevTools
# - Stack: Setup-DevTools 
# Recursos Criados:
#   - KMS
#   - Bucket de artefatos
#   - Lambda que cria pipelines
#   - Role para a Pipeline
echo Creating Stack Setup-DevTools @ DevTools - $DevToolsAccount using $ProfileDevToolsAccount profile
aws cloudformation deploy --stack-name Setup-DevTools  --template-file DevTools-Account/DevTools-Setup.yaml \
--parameter-overrides DevOpsAccount=$DevOpsAccount DevAccount=$DevAccount HomologAccount=$HomologAccount ProdAccount=$ProdAccount TemplateURL=$TemplateURL \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileDevToolsAccount

aws cloudformation wait stack-create-complete --stack-name Setup-DevTools --profile $ProfileDevToolsAccount

##### Variaveis criadas após execução do DevTools-Setup
## BucketArtifact
BucketArtifact=$(aws ssm get-parameters --names /Shared/BucketArtifact --query "Parameters[*].{Value:Value}" --output text --profile $ProfileDevToolsAccount)
echo BucketArtifact: $BucketArtifact

## KMSKeyArn
KMSKeyArn=$(aws ssm get-parameters --names /Shared/KMSKeyArn --query "Parameters[*].{Value:Value}" --output text --profile $ProfileDevToolsAccount)
echo KMSKeyArn: $KMSKeyArn



######################################## CrossAccountRoleSharedLibs
# - Conta: DevOps
# - Stack: CrossAccountRoleSharedLibs
# Recursos Criados:
#       - Role Cross Account para acesso ao CodeCommit e ao BucketS3
#         Nome da Role criada: CrossAccountRoleSharedLibs
echo Creating Stack CrossAccountRoleSharedLibs @ DevOpsAccount - $DevOpsAccount using $ProfileDevOpsAccount profile

aws cloudformation deploy --stack-name CrossAccountRoleSharedLibs --template-file DevSecOps-Account/DevOps-CrossAccountRoleSharedLibs.yaml \
--parameter-overrides DevToolsAccount=$DevToolsAccount BucketArtifact=$BucketArtifact KMSKeyArn=$KMSKeyArn \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileDevOpsAccount 

aws cloudformation wait stack-create-complete --stack-name CrossAccountRoleSharedLibs --profile $ProfileDevOpsAccount 



######################################## CrossAccountRole
# - Conta: Dev / Homolog / Prod
# - Stack: CrossAccountRole
# Recursos Criados:
#       - Role Cross Account para ser assumida pelo Pipeline na conta DevTools
#         Nome da Role criada: CrossAccountRole
echo Creating Stack CrossAccountRole @ DevAccount - $DevAccount using $ProfileDevAccount profile
echo Creating Stack CrossAccountRole @ HomologAccount - $HomologAccount using $ProfileHomologAccount profile
echo Creating Stack CrossAccountRole @ ProdAccount - $ProdAccount using $ProfileProdAccount profile

aws cloudformation deploy --stack-name CrossAccountRole --template-file DevHomProd-Accounts/GroupAccounts-CrossAccountRole.yaml \
--parameter-overrides DevToolsAccount=$DevToolsAccount BucketArtifact=$BucketArtifact KMSKeyArn=$KMSKeyArn \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileDevAccount \
&
aws cloudformation deploy --stack-name CrossAccountRole --template-file DevHomProd-Accounts/GroupAccounts-CrossAccountRole.yaml \
--parameter-overrides DevToolsAccount=$DevToolsAccount BucketArtifact=$BucketArtifact KMSKeyArn=$KMSKeyArn \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileHomologAccount \
&
aws cloudformation deploy --stack-name CrossAccountRole --template-file DevHomProd-Accounts/GroupAccounts-CrossAccountRole.yaml \
--parameter-overrides DevToolsAccount=$DevToolsAccount BucketArtifact=$BucketArtifact KMSKeyArn=$KMSKeyArn \
--capabilities CAPABILITY_NAMED_IAM \
--profile $ProfileProdAccount

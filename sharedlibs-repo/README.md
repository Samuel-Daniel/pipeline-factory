# Bibliotecas Compartilhas para Pipeline AWS

## Pré-requisitos para criação/execução da Pipeline

A conta DevTools deve conter as seguintes valores preenchidos na `Parameter Store`:

Esses dados devem ser preenchidos na criação da conta.

| **Chave** | **Descrição** |
|-------|-----------|
|**/cross/account-dev**|Conta de Desenvolvimento do Projeto|
|**/cross/account-hom**|Conta de Homologação do Projeto|
|**/cross/account-prod**|Conta de Produção do Projeto|
|**/cross/account-devsecops**|Conta cross para acesso do shared library|
|**/pipeline/cmkarn**|ARN da chave do KMS |
|**/pipeline/s3bucket-cmk**|ARN da bucket da chave do KMS  |
|**/pipeline/region-dev**|ARN do registry do ECR local |
|**/pipeline/region-hom**|ARN do registry do ECR da conta de Desenvolvimento|
|**/pipeline/region-prod**|ARN do registry do ECR da conta de Homologação|
|**/pipeline/aqua/token**|Token do micronscan do Aqua|

## Parâmetros da pipeline

|**Parâmetro**|**Descrição**|
|---------|---------|
|**ProjetName**|Nome do Projeto  |
|**RepoName**|ARN do Repositório do codecommit |
|**BranchName**|Nome Branch para deploy (Padrão: master)|
|**Runtime**|Plataforma para build da Pipeline|


## Parâmetros Opcionais

|**Parâmetro**|**Descrição**|
|---------|---------|
|**CrossAccountCondition**|Condição para assumer Role (Padrão: False)  |
|**PublishCondition**|Condição para publicar a imagem no ECR (Padrão: False) |
|**ShardLibraryBranchName**|Nome da Branch do shared Library (Padrão: master)|


## Tecnologia Suportada


|Java|DotNet|Python|
|----|------|------|
|[SonarQube](java/sonarqube/buildspec.yml)        | `SonarQube`                                    | `SonarQube` |
|[SAST](java/sast/buildspec.yml)       | `SAST`                                    | `SAST`|
|[Build](java/build/buildspec.yml)        | [Build](dotnet/build/buildspec.yml)      | [Build](dotnet/build/buildspec.yml)|
|[TestUnit](java/testunit/buildspec.yml)  | [TestUnit](dotnet/testunit/buildspec.yml)| [TestUnit](dotnet/testunit/buildspec.yml)|
|[Container-Security](java/container-security/buildspec.yml)          | [Container-Security](dotnet/container-security/buildspec.yml)        | [Container-Security](dotnet/container-security/buildspec.yml)|
|[Publish](java/publish/buildspec.yml)    | [Publish](dotnet/publish/buildspec.yml)  | [Publish](dotnet/publish/buildspec.yml)|

# Tecnologias por Stages

1. SonarQube   : `SonarQube` 
2. SAST: `Fortify`
3. Build: `AWS CodeBuild`
4. TestUnit: `AWS CodeBuild`
5. Container-Security : `Aqua MicroScanner`
6. Publish: `Docker Push`
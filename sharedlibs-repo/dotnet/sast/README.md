
# Scan do Fortify

A execu&ccedil;&atilde;o da etapa de scan do Fortify, est&aacute; divid&iacute;da em quatro etapas:

## Pr&eacute;-build

Nesta etapa o Fortify ser&aacute; baixado do reposit&oacute;rio mantido por seguran&ccedil;a e instalado dentro do CodeBuild.

## Build

Nesta etapa, ser&aacute; executado o build da aplica&ccedil;&otilde; e aplicado o scaner sobre a aplica&ccedil;&atilde; e gerado o report no formato **fpr**.

## Post-build

Nesta etapa &eacute; feita a convers&atilde;o do report gerado na etapa anterior para o formato **pdf**.

## Sa&iacute;da

Os reports gerados, ser&atilde;o armazenados em um bucket S3 em uma pasta com o node do ID do build.
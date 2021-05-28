# remuneracao
dataset que contém arquivos da consulta de remuneração mensal dos servidores

## Instalação e configuração

Instruções sobre instalação dos pré-requisitos e configuração do ambiente estão disponíves no arquivo [INSTALL](INSTALL.md)

## Instruções - Publicação de um único mês

Antes da execução das rotinas é necessário um pré-processamento manual para padronização dos arquivos e os mesmos devem ser salvos na pasta `data-raw` com os nomes

```
data-raw/servidores-AAAA-MM-civis.csv
data-raw/servidores-AAAA-MM-cbmmg.xlsx
data-raw/servidores-AAAA-MM-pmmg.xlsx
```

O pré-processamento consiste em padronizar os cabeçalhos de todos os arquivos de acordo com os campos definidos no `schema.json`.

Para executar os scripts necessários para consolidação, limpeza e validação do recurso de um único mês execute na linha de comando

```sh
make extract resource=servidores-AAAA-MM # download dos arquivos originais do google drive
make merge resource=servidores-AAAA-MM # gera arquivo consolidado data-raw/servidores-AAAA-MM.csv
make clean resource=servidores-AAAA-MM # gera arquivo data/servidores-AAAA-MM.csv
make validate resource=servidores-AAAA-MM > logs/validation.txt
```

### Testes

A validação feita em `make validate` é para garantir a validade dos aspectos estruturais das planilhas. Além disso, para garantia adicional de qualidade é necessário a verificação de regras de negócio, implementadas por meio do pacote [validate](https://cran.r-project.org/web/packages/validate/index.html).

Para execução dos testes é necessário alterar manualmente o mês de referência no arquivo `tests/testthat/setup.R`. Os teste podem ser executados com

```sh
make test
```

Se houver erros é necessário executar os testes de forma interativa no console do R. Primeiro execute o script `tests/testthat/setup.R` e depois os scripts `tests/testthat/test_*` relevantes (ie. que tiveram mensagem de erro).

### Publicação

Para publicar o arquivo no [Portal de Dados Abertos](http://dados.mg.gov.br/dataset/remuneracao-servidores-ativos) execute na linha de comando

```sh
make publish resource=servidores-AAAA-MM
```

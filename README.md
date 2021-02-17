# remuneracao
dataset que contém arquivos da consulta de remuneração mensal dos servidores

## Pré-requisitos

### R

Esse projeto utiliza o pacote [renv](https://rstudio.github.io/renv/index.html) para gerenciamento de dependências. Ao inicializar o projeto do Rstudio, se as seguintes mensagens forem apresentadas

```r
# Bootstrapping renv 0.12.3 --------------------------------------------------
* Downloading renv 0.12.3 from CRAN ... OK
* Installing renv 0.12.3 ... Done!
* Successfully installed and loaded renv 0.12.3.
* Project 'C:/Users/m752587/projects/remuneracao' loaded. [renv 0.12.3]
* The project library is out of sync with the lockfile.
* Use `renv::restore()` to install packages recorded in the lockfile.
```

Siga as instruções e execute

```r
renv::restore()
```

Caso contrário pode ser necessário

```r
install.packages("renv") # instalação do pacote renv
renv::init() # instalação dos pacotes listados no arquivo renv.lock
```

Essa instalação demora vários minutos.

As mensagens acima somente serão exibidas na primeira vez que o `renv` for inicializado. Nas sessões seguintes, a mensagem indicativa de sucesso é simplesmente

```r
* Project '~/Local/dados-mg/ckan/remuneracao' loaded. [renv 0.12.3]
```

### Variáveis de ambiente

Para carga automática no CKAN é necessário a configuração de quatro variáveis de ambiente:

- `DADOSMG_PROD_HOST`
- `DADOSMG_PROD`
- `DADOSMG_DEV_HOST`
- `DADOSMG_DEV`


Em ambiente de produção, a variável `DADOSMG_PROD_HOST` deve estar com o valor `http://dados.mg.gov.br` e a variável `DADOSMG_PROD` com a sua [chave da API do CKAN](https://docs.ckan.org/en/ckan-2.7.3/api/#authentication-and-api-keys). Ela pode ser encontrada na sua página de usuário e parece com a string `ec5c0860-9e48-41f3-8850-4a7128b18df8`. Esse modo de autenticação foi deprecado na [versão 2.9 do CKAN](https://docs.ckan.org/en/2.9/api/index.html#authentication-and-api-tokens).

De maneira similar, em ambiente de homologação a variável `DADOSMG_DEV_HOST` deve estar com o valor `http://homologa.cge.mg.gov.br` e com a chave apropriada do seu usuário de homologação.

O código que de fato controla em qual ambiente a carga será efetuada está no script `scripts/lib/ckan.R` e deve ser alterado manualmente.

Preferenciamente defina as variáveis de ambiente utilizando um arquivo `.Renviron` na sua home folder (ie. fora da pasta do projeto para evitar commit acidental). Explicações [aqui](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf). Para determinar sua home folder execute no console do R.

```r
Sys.getenv("HOME")
# /Users/fjunior
```

Nesse exemplo, o arquivo `.Renviron` deve ser criado na pasta `/Users/fjunior` por qualquer meio. Para criar pela linha de comando use

```sh
touch /Users/fjunior/.Renviron # cria o arquivo caso não exista
subl /Users/fjunior/.Renviron # edite o arquivo
```

### Python

Para validação dos recursos é necessário a instalação do Python e da biblioteca goodtables. Para fazer essas etaptas execute os seguintes comandos no console do R:

```R
reticulate::install_miniconda() # instalacao do python via miniconda
reticulate::conda_create("remuneracao") # criacao de ambiente conda especifico para esse projeto
reticulate::conda_install("remuneracao", "goodtables==2.5.2") # instalacao da versao correta do goodtables
```

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
make merge resource=servidores-AAAA-MM # gera arquivo consolidado data-raw/servidores-AAAA-MM.csv
make clean resource=servidores-AAAA-MM # # gera arquivo data/servidores-AAAA-MM.csv
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

## Instruções - Reproduzir série histórica

Na versão `datapackage$version` desse conjunto de dados foi necessário realizar um tratamento na série histórica dos arquivos para adequação ao documentado no `datapackage.json`.

Além disso, foi necessário:

- restringir as unidades administrativas;
- corrigir os valores da remuneração do CBMMG.

Essa tratamento ocorreu uma única vez, com a seguinte sequência de scripts:

- `download_servidores.R` Download de 91 arquivos (jun/2012 até dez/2019) para `data-raw/servidores/` que sofreram tratamentos manuais descritos [aqui](https://docs.google.com/document/d/1xlcs-FAdQoI7le970bFshQiw_6V_uuOz/edit)

- `download_cbmmg.R` Download de 84 arquivos (jan/2012 até dez/2018) para `data-raw/cbmmg/`. As seguintes alterações manuais devem ser feitas:
    
    - Os meses de jan/2012 a mai/2012 (5 arquivos) devem ser excluídos pois a série histórica da planilha de remuneração se inicia em jun/2012
    - O mês de fev/2017 demanda ajuste manual nas últimas colunas antes da execução dos demais scripts

Essas operações podem ser executadas com

```sh
make download
```

- `clean_cbmmg.R` Limpeza e padronização das planilhas `data-raw/cbmmg/` e _staging_ em `data/cbmmg/`

## Regras de validação

### Consistência campo calculado - remuneração líquida

- Remunerações Após Deducões Obrigatórias (`rem_pos`) =
    - (+) Remuneração Básica Bruta (`remuner`)
    - (-) Abate Teto Valor (`teto`)
    - (+) Férias (`ferias`)
    - (+) Gratificação Natal (`decter`)
    - (+) Prêmio Produtividade `(premio`)
    - (+) Férias-Prêmio (`feriasprem`)
    - (+) Jetons Folha (`jetons`)
    - (+) Demais Eventuais (`eventual`)
    - (-) IRPF (`ir`)
    - (-) Contribuição Previdenciária (`prev`)

### Normalização de texto

- Espaço entre palavras
    - UTRAMIG FUND EDUC PARA O TRAB (57/100 vezes)
    - UTRAMIG-FUND.EDUC.PARA O TRAB. (43/100 vezes)

# Links

- [POP Planilha Remuneração](https://onedrive.live.com/?id=8686837A27156968%2148766&cid=8686837A27156968)
- [Planilhas originais - Drive](https://drive.google.com/drive/u/0/folders/1hVdlauJdtyLs0c1X0i1mfTGHoAga1j_n)

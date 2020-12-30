.PHONY: help all clean sync build publish

#====================================================================
# PHONY TARGETS

help: 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

all: clean

download:
	Rscript --verbose scripts/download_servidores.R 2> logs/log.Rout

transform:
	cp data-raw/servidores/* data/

clean: ## Clean resource
	Rscript --verbose scripts/clean-resource.R $(resource) 2> logs/log.Rout

validate: ## Validate resource
	Rscript --verbose scripts/validate-resource.R $(resource) 2> logs/log.Rout

publish: ## Publish resource
	Rscript --verbose scripts/publish-resource.R $(resource) 2> logs/log.Rout	
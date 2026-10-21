.PHONY: fmt validate
fmt:
	terraform fmt -recursive
validate:
	bash scripts/validate.sh

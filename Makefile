.PHONY: fmt validate lint plan init docs clean

ENVIRONMENT ?= dev

fmt:
	terraform fmt -recursive

validate:
	@echo "==> Validating modules..."
	@for dir in modules/*/; do \
		echo "  -> $$dir"; \
		terraform -chdir=$$dir init -backend=false -input=false > /dev/null 2>&1; \
		terraform -chdir=$$dir validate; \
	done
	@echo "==> Validating environments..."
	@for dir in environments/*/; do \
		echo "  -> $$dir"; \
		terraform -chdir=$$dir init -backend=false -input=false > /dev/null 2>&1; \
		terraform -chdir=$$dir validate; \
	done

lint:
	@echo "==> Running TFLint..."
	@for dir in modules/*/; do \
		echo "  -> $$dir"; \
		tflint --chdir=$$dir; \
	done

plan:
	@echo "==> Planning $(ENVIRONMENT)..."
	terraform -chdir=environments/$(ENVIRONMENT) init -input=false
	terraform -chdir=environments/$(ENVIRONMENT) plan -out=tfplan

apply:
	@echo "==> Applying $(ENVIRONMENT)..."
	terraform -chdir=environments/$(ENVIRONMENT) apply tfplan

init:
	@echo "==> Initializing $(ENVIRONMENT)..."
	terraform -chdir=environments/$(ENVIRONMENT) init -input=false

docs:
	@echo "==> Generating module documentation..."
	@for dir in modules/*/; do \
		echo "  -> $$dir"; \
		terraform-docs markdown table $$dir > $$dir/README.md 2>/dev/null || true; \
	done

clean:
	@echo "==> Cleaning Terraform caches..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true

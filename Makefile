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
	@echo "    (NOTE: .terraform.lock.hcl is intentionally preserved for"
	@echo "     environments/* and examples/* — see ADR-008. Modules'"
	@echo "     lock files are not versioned and can be removed safely.)"
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	find ./modules -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true

lock:
	@echo "==> Refreshing provider lock files for all root modules (all platforms)..."
	@for dir in environments/*/ examples/*/; do \
		echo "  -> $$dir"; \
		terraform -chdir=$$dir providers lock \
			-platform=linux_amd64 \
			-platform=darwin_amd64 \
			-platform=darwin_arm64 \
			-platform=windows_amd64; \
	done

lock-check:
	@echo "==> Verifying provider lock file consistency for all root modules..."
	@status=0; \
	for dir in environments/*/ examples/*/; do \
		echo "  -> $$dir"; \
		if [ ! -f "$$dir/.terraform.lock.hcl" ]; then \
			echo "     ERROR: missing .terraform.lock.hcl in $$dir"; \
			status=1; \
			continue; \
		fi; \
		rm -rf $$dir/.terraform; \
		terraform -chdir=$$dir init -backend=false -input=false -lockfile=readonly > /dev/null || status=1; \
	done; \
	exit $$status

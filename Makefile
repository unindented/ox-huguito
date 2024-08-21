EMACS ?= emacs
MATCH ?=

.PHONY: test
test:
	@$(EMACS) --quick --batch \
		--directory tests/ \
		--load tests/org-test.el \
		--load tests/test-all.el \
		-eval '(ert-run-tests-batch-and-exit "$(MATCH)")'

.PHONY: test-watch
test-watch:
	@while sleep 0.1; do git ls-files -cdmo --exclude-standard | entr -cd make; done

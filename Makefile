.PHONY: clean test upgrade quality requirements quality-python test-js test-python \
		install-js test-bokchoy check_keywords

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## display this help message
	@echo "Please use \`make <target>\` where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

ifdef TOXENV
TOX := tox -- #to isolate each tox environment if TOXENV is defined
endif

clean: ## delete generated byte code and coverage reports
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} ';' || true
	coverage erase
	rm -rf coverage htmlcov
	rm -rf assets
	rm -rf pii_report

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade: ## update the requirements/*.txt files with the latest packages satisfying requirements/*.in
	pip install -q -r requirements/pip_tools.txt
	pip-compile --rebuild --upgrade --allow-unsafe -o requirements/pip.txt requirements/pip.in
	pip-compile --upgrade -o requirements/pip_tools.txt requirements/pip_tools.in
	pip-compile --upgrade -o requirements/base.txt requirements/base.in
	pip-compile --upgrade -o requirements/testing.txt requirements/testing.in
	# Let tox control the Django version for tests
	grep -e "^django==" requirements/base.txt > requirements/django.txt
	sed -i.tmp '/^[dD]jango==/d' requirements/testing.txt
	rm requirements/testing.txt.tmp

install-js: ## install JavaScript dependencies
	npm install

quality-python: ## Run python linters
	tox -e quality

quality: quality-python ## Run linters

requirements: ## install development environment requirements
	pip install -q -r requirements/pip_tools.txt
	pip install -qr requirements/base.txt --exists-action w
	pip-sync requirements/base.txt requirements/testing.txt

test-js: ## run tests using npm
	-./node_modules/gulp/bin/gulp.js test

test-python: clean ## run tests using pytest and generate coverage report
	$(TOX)pytest --ignore=testserver/test/acceptance

test-bokchoy:	## run tests using bokchoy
	bash ./run_bokchoy_tests.sh

test: test-js test-python test-bokchoy ## run tests

check_keywords: ## Scan the Django models in all installed apps in this project for restricted field names
	python manage.py check_reserved_keywords --override_file db_keyword_overrides.yml

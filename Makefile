SHELL := /bin/bash

VENV := venv.nix
VENV_BIN := ${VENV}/bin
PIP := ${VENV_BIN}/pip
PYTHON := ${VENV_BIN}/python3
TOX := ${VENV_BIN}/tox

PROJECT := `${VENV_BIN}/toml get --toml-path pyproject.toml project.name`
VERSION := `${VENV_BIN}/toml get --toml-path pyproject.toml project.version`

TESTPUBLISH_VENV := venv.nix.testpublish
TESTPUBLISH_PYTHON := ${TESTPUBLISH_VENV}/bin/python3

# Disable built-in make rules
MAKEFLAGS += --no-builtin-rules

.PHONY: setup
setup: mrclean
	python -m venv ${VENV}
	${PIP} install -U pip
	${PIP} install -r dev-requirements.txt
	uv python install 3.13 3.12 3.11 3.10 3.9

.PHONY: dev-setup
dev-setup: setup install-editable

.PHONY: install-editable
install-editable:
	${PIP} install --editable .

.PHONY: build
build: lint bom.json test
	${TOX} -e build

.PHONY: clean
clean:
	rm -rf dist
	find src -type f -name "*.pyc" -exec rm -f {} \;
	find tests -type f -name "*.pyc" -exec rm -f {} \;
	rm -rf src/violetbeacon_deptrack_client.egg-info

.PHONY: mrclean
mrclean: clean
	rm -rf ${VENV}
	rm -rf ${TESTPUBLISH_VENV}
	rm -rf .tox
	rm -rf .mypy_cache
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -f .coverage
	rm -f bom.json

bom.json: pyproject.toml
	${TOX} run -e cyclonedx

.PHONY: cyclonedx-upload
cyclonedx-upload: bom.json
	if [[ -e ../_private/deptrack-client.env ]]; then \
			source ../_private/deptrack-client.env; \
		fi \
		&& ${VENV_BIN}/deptrack-client upload-bom -a -p ${PROJECT} -q ${VERSION} -f bom.json

.PHONY: install-uv
install-uv:
	pip install uv

# Note: We need to use dev-setup in order to install deptrack-client in editable
# mode since we use it in cyclonedx-upload
.PHONY: cicd
cicd: install-uv dev-setup bom.json cyclonedx-upload tox-all

.PHONY: lint
lint:
	${TOX} run-parallel -e lint,type

.PHONY: audit
audit:
	${TOX} run -e audit

.PHONY: test
test:
	${TOX} run -e coverage

.PHONY: test-all
test-all:
	${TOX} run-parallel -e 3.13,3.12,3.10,3.9

.PHONY: tox-all
tox-all:
	${TOX} run-parallel

.PHONY: publish-test
publish-test:
	${PYTHON} -m twine upload --repository testpypi dist/*

.PHONY: verify-publish-test
verify-publish-test:
	rm -rf ${TESTPUBLISH_VENV}
	python -m venv ${TESTPUBLISH_VENV}
	${TESTPUBLISH_PYTHON} -m pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ ${PROJECT}
	echo "VALIDATING: deptrack-client version"
	${TESTPUBLISH_VENV}/bin/deptrack-client version

.PHONY: publish
publish:
	${PYTHON} -m twine upload dist/*

.PHONY: verify-publish
verify-publish:
	rm -rf ${TESTPUBLISH_VENV}
	python -m venv ${TESTPUBLISH_VENV}
	${TESTPUBLISH_PYTHON} -m pip install ${PROJECT}
	echo "VALIDATING: deptrack-client version"
	${TESTPUBLISH_VENV}/bin/deptrack-client version

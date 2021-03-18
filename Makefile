pipenv-setup:
	pipenv install --dev --python 3.8

build-dist-code-only:
	@mkdir -p dist
	cp function/*.py dist/

build-dist: build-dist-code-only
	pipenv run python -m pip install -r requirements.txt -t dist

teardown-local-env:
	docker-compose down --remove-orphans --volumes --timeout=3

bootstrap-local-env: teardown-local-env
	docker-compose up --detach

test-unit:
	PIPENV_DOTENV_LOCATION=test.env PYTHONPATH=dist \
		pipenv run pytest tests/unit -vv

test-e2e-no-setup: build-dist-code-only
	PIPENV_DOTENV_LOCATION=test.env PYTHONPATH=dist \
		pipenv run pytest tests/e2e -vv

test-e2e: bootstrap-local-env build-dist test-e2e-no-setup
	docker-compose down --remove-orphans --volumes --timeout=3

test: test-unit test-e2e

terraform-plan:
	terraform plan terraform

terraform-apply:
	terraform apply terraform

deploy:
	rm function.zip || true
	cd dist && zip --quiet --recurse-paths ../function.zip ./* && cd ..
	aws s3 cp function.zip s3://lambda-poc-unique-name-lambda-source/poc_report/stable.zip
	terraform apply terraform

.SHELL := /bin/bash
.PHONY = test

test:
	shellcheck ./unittests/run_test_cases.sh
	cd ./unittests && ./run_test_cases.sh

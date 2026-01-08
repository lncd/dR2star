.PHONY: docker check coverage 
check: .make/check
docker: .make/docker
coverage: .make/coverage
TESTFILES := $(wildcard t/*)
DOCKERNAME := lncd/tat2
TAT2VER := `grep -Po '(?<=TAT2_VER=")[^"-]*' tat2`

.make/check: $(TESTFILES) | .make/
	bats --tap t/ | tee $@

.make/docker: Dockerfile tat2 | .make
	docker build -f Dockerfile  -t $(DOCKERNAME):$(TAT2VER)
	TAT2_TEST_DOCKER=1 bats t/tat2-fmriprep.bats
	docker image inspect $(DOCKERNAME):$(TAT2VER) > $@


.make/coverage: $(TESTFILES)
	kcov --bash-dont-parse-binary-dir --exclude-path=/usr,/tmp t/coverage/ bats t/ | tee $@

.make/:
	mkdir -p $@

check-zenodo:
	 npx zenodraft metadata validate .zenodo.json

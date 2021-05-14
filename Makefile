DIRS := epics-base \
	pvDataCPP \
	pvAccessCPP \
	pva2pva \
	pvaClientCPP \
	p4p \
	normativeTypesCPP \
	exampleCPP

THIS_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: $(DIRS) all clean

all: $(DIRS)

RELEASE.local: RELEASE.local.in
	sed -e "s|@THIS_DIR@|${THIS_DIR}|g" RELEASE.local.in > RELEASE.local

clean: RELEASE.local
	$(foreach dir, $(DIRS), make -C $(dir) clean;)

p4p_deps:
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./p4p)" ] && git submodule update --init p4p
	python3 -m pip install -r p4p/requirements-latest.txt --user

$(DIRS): RELEASE.local p4p_deps
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	make -C $@ -j8

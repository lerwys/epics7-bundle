EPICS7_DIRS := epics-base \
	pvDataCPP \
	pvAccessCPP \
	pva2pva \
	normativeTypesCPP \
	pvaClientCPP \
	p4p

THIS_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: $(EPICS7_DIRS) asyn all clean

all: $(EPICS7_DIRS) asyn

RELEASE.local: RELEASE.local.in
	sed -e "s|@THIS_DIR@|${THIS_DIR}|g" RELEASE.local.in > RELEASE.local

clean: RELEASE.local
	$(foreach dir, $(EPICS7_DIRS), make -C $(dir) clean;)

p4p_deps:
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./p4p)" ] && git submodule update --init p4p
	python3 -m pip install -r p4p/requirements-latest.txt --user

$(EPICS7_DIRS): RELEASE.local p4p_deps
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	make -C $@ -j8

asyn: RELEASE.local
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	sed -i \
		-e 's/^\(IPAC=.*\)/#\1/g' \
		-e 's/^\(SNCSEQ=.*\)/#\1/g' \
		-e 's/^\(EPICS_BASE=.*\)/#\1/g' \
		asyn/configure/RELEASE
	make -C $@ -j8

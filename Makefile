DIRS := epics-base \
	pvDataCPP \
	pvAccessCPP \
	pva2pva \
	pvaClientCPP \
	normativeTypesCPP \
	exampleCPP

THIS_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: $(DIRS) all clean

all: $(DIRS)

RELEASE.local: RELEASE.local.in
	sed -e "s|@THIS_DIR@|${THIS_DIR}|g" RELEASE.local.in > RELEASE.local

clean: RELEASE.local
	$(foreach dir, $(DIRS), make -C $(dir) clean;)

$(DIRS): RELEASE.local
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	make -C $@ -j8

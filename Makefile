DIRS := epics-base pvDataCPP pvAccessCPP pva2pva pvaClientCPP normativeTypesCPP exampleCPP

.PHONY: $(DIRS)

all: $(DIRS)

$(DIRS):
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	make -C $@ -j8

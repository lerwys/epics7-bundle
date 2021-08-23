EPICS7_DIRS := epics-base \
	pvDataCPP \
	pvAccessCPP \
	pvDatabaseCPP \
	pva2pva \
	normativeTypesCPP \
	pvaClientCPP \
	p4p

define AREA_DETECTOR_CONFIG_SITE_LOCAL
WITH_PVA = YES
BUILD_IOCS = YES
XML2_EXTERNAL = YES
XML2_INCLUDE = /usr/include/libxml2
endef

define AREA_DETECTOR_RELEASE_PRODS_LOCAL
-include $$(AREA_DETECTOR)/../RELEASE.local
endef

define ADCORE_RELEASE_LOCAL
-include $$(TOP)/../RELEASE.local
endef

define ADSIMDETECTOR_RELEASE_LOCAL
-include $$(TOP)/../RELEASE.local
endef

define ADSIMDETECTOR_IOC_RELEASE_LOCAL
-include $$(TOP)/../../../RELEASE.local
endef

THIS_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: $(EPICS7_DIRS) p4p_deps asyn areaDetector ADCore ADCore_deps ADSimDetector all clean

all: $(EPICS7_DIRS) asyn areaDetector ADCore

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

asyn: epics-base RELEASE.local
	[ -z "$(ls -A ./$@)" ] && git submodule update --init $@
	sed -i \
		-e 's/^\(IPAC=.*\)/#\1/g' \
		-e 's/^\(SNCSEQ=.*\)/#\1/g' \
		-e 's/^\(EPICS_BASE=.*\)/#\1/g' \
		asyn/configure/RELEASE
	make -C $@ -j8

areaDetector: areaDetectorMeta ADCoreMeta ADSimDetectorMeta RELEASE.local
	make -C $@ -j8

export AREA_DETECTOR_CONFIG_SITE_LOCAL
export AREA_DETECTOR_RELEASE_PRODS_LOCAL
areaDetectorMeta:
	[ -z "$(ls -A ./areaDetector)" ] && git submodule update --init areaDetector
	echo "$$AREA_DETECTOR_CONFIG_SITE_LOCAL" > areaDetector/configure/CONFIG_SITE.local
	echo "$$AREA_DETECTOR_RELEASE_PRODS_LOCAL" > areaDetector/configure/RELEASE_PRODS.local

ADCore_deps:
	[ -z "$(ls -A ./ADCore)" ] && git submodule update --init ADCore
	sudo apt install libxml2-dev

export ADCORE_RELEASE_LOCAL
ADCoreMeta: ADCore_deps
	[ -z "$(ls -A ./ADCore)" ] && git submodule update --init ADCore
	echo "$$ADCORE_RELEASE_LOCAL" > ADCore/configure/RELEASE.local

export ADSIMDETECTOR_RELEASE_LOCAL
export ADSIMDETECTOR_IOC_RELEASE_LOCAL
ADSimDetectorMeta:
	# Do git submodule init/update if not available
	[ -z "$(ls -A ./ADSimDetector)" ] && git submodule update --init ADSimDetector
	echo "$$ADSIMDETECTOR_RELEASE_LOCAL" > ADSimDetector/configure/RELEASE.local
	echo "$$ADSIMDETECTOR_IOC_RELEASE_LOCAL" > ADSimDetector/iocs/simDetectorIOC/configure/RELEASE.local
	echo "$$ADSIMDETECTOR_IOC_RELEASE_LOCAL" > ADSimDetector/iocs/simDetectorNoIOC/configure/RELEASE.local

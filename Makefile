# -*- Makefile -*-
# ======================================================================

PACKAGES = \
  acmacs-base \
  locationdb \
  acmacs-chart-2 \
  hidb-5 \
  seqdb \
  acmacs-draw \
  acmacs-map-draw \
  acmacs-tree-maker \
  signature-page \
  ssm-report \
  acmacs-whocc \
  acmacs-webserver \
  acmacs-api \
  acmacs.r

all: update-and-build

include Makefile.config

# ----------------------------------------------------------------------

ifneq ($(dir $(CURDIR)),$(AD_SOURCES)/)
  $(error acmacs-build must be placed in $(AD_SOURCES) (currently in $(CURDIR)))
endif

update-and-build: make-dirs update-packages install-makefiles install-dependencies

make-dirs: $(AD_INCLUDE) $(AD_LIB) $(AD_SHARE) $(AD_BIN) $(AD_PY) $(AD_DATA)

install-makefiles: $(AD_SHARE)/Makefile.config

update-packages: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))
	echo update $^

install-dependencies:
# install_pybind11
# install_rapidjson
# install_boost
# install_websocketpp
# install_libbson_for_mongodb2
# install_mongo_c_driver_for_mongodb2
# install_mongo_cxx_driver_for_mongodb2

$(AD_SOURCES)/acmacs-base:
	if [[ -d $@ ]]; then \
	  echo Updating $@; \
	  cd $@; git pull -q || exit 1; \
	fi

$(ACMACSD_ROOT)/%:
	mkdir -p $@

$(AD_SHARE)/Makefile.%:
	ln -sf $(abspath $(notdir $@)) $(AD_SHARE)

.PHONY: update-and-build git-update make-dirs install-dependencies install-makefiles
.PHONY: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

# ======================================================================
### Local Variables:
### eval: (if (fboundp 'eu-rename-buffer) (eu-rename-buffer))
### End:

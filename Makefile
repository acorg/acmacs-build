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

ifeq ($(USER),eu)
  GIT_URI = git@github.com:acorg
else
  GIT_URI = https://github.com/acorg
endif

ifeq ($(TEST),1)
  PACKAGE_TARGET = test
else
  PACKAGE_TARGET = all
endif

# old makefiles support
ifeq ($(DEBUG),1)
  T = D
else
  T = R
endif
export T

# ----------------------------------------------------------------------

ifneq ($(dir $(CURDIR)),$(AD_SOURCES)/)
  $(error acmacs-build must be placed in $(AD_SOURCES) (currently in $(CURDIR)))
endif

update-and-build: build-packages

make-dirs: $(AD_INCLUDE) $(AD_LIB) $(AD_SHARE) $(AD_BIN) $(AD_PY) $(AD_DATA)

install-makefiles: $(AD_SHARE)/Makefile.config

update-packages: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

build-packages: make-dirs update-packages install-makefiles install-dependencies
	for package in $(PACKAGES); do \
	  echo Building $$package; \
	  $(MAKE) -C $(AD_SOURCES)/$$package $(PACKAGE_TARGET) || exit 1; \
	done

install-dependencies:
# install_pybind11
# install_rapidjson
# install_boost
# install_websocketpp
# install_libbson_for_mongodb2
# install_mongo_c_driver_for_mongodb2
# install_mongo_cxx_driver_for_mongodb2

help: help-vars
	printf "\nVariables:\n"
	printf "\tTEST=1 - run tests\n"
	printf "\n"
	printf "Targets:\n\tupdate-and-build\n\n"

$(patsubst %,$(AD_SOURCES)/%,$(PACKAGES)):
	if [ -d $@ ]; then \
	  echo Pulling in $@; \
	  cd $@; git pull -q || exit 1; \
	else \
	  echo Cloning to $@; \
	  git clone $(GIT_URI)/$(notdir $@).git $@; \
	fi

$(AD_INCLUDE) $(AD_LIB) $(AD_SHARE) $(AD_BIN) $(AD_PY) $(AD_DATA):
	mkdir -p $@

$(AD_SHARE)/Makefile.%:
	ln -sf $(abspath $(notdir $@)) $(AD_SHARE)

.PHONY: update-and-build git-update make-dirs install-dependencies install-makefiles
.PHONY: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

# ======================================================================
### Local Variables:
### eval: (if (fboundp 'eu-rename-buffer) (eu-rename-buffer))
### End:

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

NO_CLEAN_TARGET = 1
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

ifneq ($(dir $(CURDIR)),$(realpath $(AD_SOURCES))/)
  $(error acmacs-build must be placed in $(realpath $(AD_SOURCES)) (currently in $(CURDIR)))
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

install-dependencies: pybind11 websocketpp
	$(MAKE) -f Makefile.mongocxx
.PHONY: install-dependencies

PYBIND11_PREFIX = $(BUILD)
PYBIND11_DIR = $(BUILD)/pybind11

pybind11:
	$(call git_clone_or_pull,$(PYBIND11_DIR),https://github.com/pybind)
	$(call symbolic_link,$(PYBIND11_DIR)/include/pybind11,$(AD_INCLUDE)/pybind11)

WEBSOCKETPP_PREFIX = $(BUILD)
WEBSOCKETPP_DIR = $(BUILD)/websocketpp

websocketpp:
	$(call git_clone_or_pull,$(WEBSOCKETPP_DIR),https://github.com/zaphoyd)
	$(call symbolic_link,$(WEBSOCKETPP_DIR)/websocketpp,$(AD_INCLUDE)/websocketpp)

clean:
	rm -rf $(ACMACSD_ROOT)/build

help: help-vars
	printf "\nVariables:\n"
	printf "\tTEST=1 - run tests\n"
	printf "\n"
	printf "Targets:\n\tupdate-and-build\n\n"

$(patsubst %,$(AD_SOURCES)/%,$(PACKAGES)):
	$(call git_clone_or_pull,$@,$(GIT_URI))

$(AD_BIN) $(AD_INCLUDE) $(AD_LIB) $(AD_PY) $(AD_SHARE): $(AD_BUILD)
	mkdir -p $(AD_BUILD)/$(@F) && if [ ! -L $@ ]; then rm -f $@; ln -sv $(AD_BUILD)/$(@F) $@; fi

$(AD_DATA): $(AD_BUILD)
	mkdir -p $@

$(AD_SHARE)/Makefile.%: | $(AD_SHARE)
	ln -svf $(abspath $(@F)) $@

.PHONY: update-and-build git-update make-dirs install-dependencies install-makefiles
.PHONY: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

# ======================================================================
### Local Variables:
### eval: (if (fboundp 'eu-rename-buffer) (eu-rename-buffer))
### End:

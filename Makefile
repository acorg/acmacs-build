# -*- Makefile -*-
# ======================================================================

PACKAGES_CXX = \
  acmacs-base \
  locationdb \
  acmacs-virus \
  acmacs-whocc-data \
  acmacs-chart-2 \
  hidb-5 \
  seqdb-3 \
  acmacs-draw \
  acmacs-map-draw \
  acmacs-tree-maker \
  signature-page \
  acmacs-tal \
  acmacs-whocc \
  acmacs-webserver \
  acmacs-api

PACKAGES = \
  $(PACKAGES_CXX) \
  ssm-report \
  acmacs.r

all: update-and-build

NO_CLEAN_TARGET = 1
NO_RTAGS_TARGET = 1
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

# ----------------------------------------------------------------------

ifneq ($(dir $(CURDIR)),$(realpath $(AD_SOURCES))/)
  $(error acmacs-build must be placed in $(realpath $(AD_SOURCES)) (currently in $(CURDIR)))
endif

update-and-build: build-packages

install-makefiles: $(AD_SHARE)/Makefile.config

update-packages: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

build-packages: make-dirs update-packages install-makefiles install-dependencies
	for package in $(PACKAGES); do \
	  echo Building $$package; \
	  $(MAKE) -C $(AD_SOURCES)/$$package $(PACKAGE_TARGET) || exit 1; \
	done
	$(MAKE) ccls

cxx:
	for package in $(PACKAGES_CXX); do \
	  echo Building $$package; \
	  $(MAKE) -C $(AD_SOURCES)/$$package $(PACKAGE_TARGET) || exit 1; \
	done

cxx-test:
	for package in $(PACKAGES_CXX); do \
	  echo Building $$package; \
	  $(MAKE) -C $(AD_SOURCES)/$$package test || exit 1; \
	done

# ----------------------------------------------------------------------
# compilation database https://sarcasm.github.io/notes/dev/compilation-database.html
# ----------------------------------------------------------------------

ccls:
ifeq ($(PLATFORM),darwin)
	sed -e '1s/^/[\'$$'\n''/' -e '$$s/,$$/\'$$'\n'']/' $(AD_BUILD)/*/build/*.o.json > $(AD_BUILD)/compile_commands.json
	ln -sf ../build/compile_commands.json $(AD_SOURCES)
endif

# ----------------------------------------------------------------------
# rtags
# ----------------------------------------------------------------------

rtags:
	for package in $(PACKAGES); do \
	  $(MAKE) -C $(AD_SOURCES)/$$package rtags || exit 1; \
	done

install-dependencies: rapidjson fmt std_date range-v3 pybind11 websocketpp asio optim openxlsx
	$(MAKE) -f Makefile.mongocxx
.PHONY: install-dependencies

PYBIND11_PREFIX = $(BUILD)
PYBIND11_DIR = $(BUILD)/pybind11

pybind11: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(PYBIND11_DIR),https://github.com/pybind)
	$(call symbolic_link,$(PYBIND11_DIR)/include/pybind11,$(AD_INCLUDE)/pybind11)

WEBSOCKETPP_PREFIX = $(BUILD)
WEBSOCKETPP_DIR = $(BUILD)/websocketpp

websocketpp: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(WEBSOCKETPP_DIR),https://github.com/zaphoyd)
	$(call symbolic_link,$(WEBSOCKETPP_DIR)/websocketpp,$(AD_INCLUDE)/websocketpp)

# https://think-async.com/Asio/AsioStandalone.html
# https://github.com/chriskohlhoff/asio/
ASIO_TAG = asio-1-12-2
ASIO_PREFIX = $(BUILD)
ASIO_DIR = $(BUILD)/asio

asio: $(AD_INCLUDE)
	$(call git_clone_tag,$(ASIO_DIR),https://github.com/chriskohlhoff,$(ASIO_TAG))
	$(call symbolic_link,$(ASIO_DIR)/asio/include/asio,$(AD_INCLUDE)/asio)
	$(call symbolic_link,$(ASIO_DIR)/asio/include/asio.hpp,$(AD_INCLUDE)/asio.hpp)

RAPIDJSON_PREFIX = $(BUILD)
RAPIDJSON_DIR = $(BUILD)/rapidjson

rapidjson: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(RAPIDJSON_DIR),https://github.com/Tencent)
	$(call symbolic_link,$(RAPIDJSON_DIR)/include/rapidjson,$(AD_INCLUDE)/rapidjson)

FMT_PREFIX = $(BUILD)
FMT_DIR = $(BUILD)/fmt
FMT_URL = "https://github.com/fmtlib/fmt/releases/download/7.0.3/fmt-7.0.3.zip"

# https://github.com/fmtlib/fmt
fmt: $(AD_INCLUDE) $(AD_LIB)
	rm -rf $(BUILD)/*fmt*
	curl -sL -o $(BUILD)/release-fmt.zip "$(FMT_URL)"
	cd $(BUILD) && unzip release-fmt.zip && ln -s fmt-* $(FMT_DIR)
	$(call symbolic_link,$(FMT_DIR)/include/fmt,$(AD_INCLUDE)/fmt)
	mkdir -p $(FMT_DIR)/build && \
	  cd $(FMT_DIR)/build && \
	  cmake -DFMT_TEST=OFF -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(FMT_PREFIX)" -DCMAKE_PREFIX_PATH="$(FMT_PREFIX)" .. && \
	  $(MAKE) install
	$(call symbolic_link,$(BUILD)/lib/libfmt.a,$(AD_LIB))

fmt-master: $(AD_INCLUDE) $(AD_LIB)
	$(call git_clone_or_pull,$(FMT_DIR),https://github.com/fmtlib)
	$(call symbolic_link,$(FMT_DIR)/include/fmt,$(AD_INCLUDE)/fmt)
	mkdir -p $(BUILD)/fmt/build && \
	  cd $(BUILD)/fmt/build && \
	  cmake -DFMT_TEST=OFF -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(FMT_PREFIX)" -DCMAKE_PREFIX_PATH="$(FMT_PREFIX)" .. && \
	  $(MAKE) install
	$(call symbolic_link,$(BUILD)/lib/libfmt.a,$(AD_LIB))

STD_DATE_PREFIX = $(BUILD)
STD_DATE_DIR = $(BUILD)/date

std_date: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(STD_DATE_DIR),https://github.com/HowardHinnant)
	$(call symbolic_link,$(STD_DATE_DIR)/include/date,$(AD_INCLUDE)/date)

# RANGEV3_BRANCH = v1.0-beta
RANGEV3_DIR = $(BUILD)/range-v3

range-v3: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(RANGEV3_DIR),https://github.com/ericniebler)
	for dd in $(RANGEV3_DIR)/include/*; do if [ ! -d $(AD_INCLUDE)/$$(basename $$dd) ]; then ln -sfv $$dd $(AD_INCLUDE); fi; done

# https://github.com/kthohr/optim
OPTIM_PREFIX = $(BUILD)
OPTIM_DIR = $(BUILD)/optim
OPTIM_INCLUDES = -I$(AD_INCLUDE)/optim

optim: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(OPTIM_DIR),https://github.com/kthohr)
	cd $(OPTIM_DIR) && ./configure --header-only-version
	$(call symbolic_link,$(OPTIM_DIR)/header_only_version,$(AD_INCLUDE)/optim)

# https://github.com/troldal/OpenXLSX
OPENXLSX_PREFIX = $(BUILD)
OPENXLSX_DIR = $(BUILD)/openxlsx
# OPENXLSX_INCLUDES = -I$(AD_INCLUDE)/openxlsx

openxlsx: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(OPENXLSX_DIR),https://github.com/troldal)
	mkdir -p $(OPENXLSX_DIR)/build && \
	  cd $(OPENXLSX_DIR)/build && \
	  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(OPENXLSX_PREFIX)" -DCMAKE_PREFIX_PATH="$(OPENXLSX_PREFIX)" .. && \
	  $(MAKE)
ifeq ($(PLATFORM),darwin)
	cp $(OPENXLSX_DIR)/build/output/libOpenXLSX-shared.dylib $(AD_LIB)/libOpenXLSX.dylib && \
	  /usr/bin/install_name_tool -id "$(AD_LIB)/libOpenXLSX.dylib" $(AD_LIB)/libOpenXLSX.dylib
else
	$(call symbolic_link,$(OPENXLSX_DIR)/build/output/libOpenXLSX-shared.so,$(AD_LIB))
endif
	mkdir -p $(AD_INCLUDE)/OpenXLSX
	$(call symbolic_link_wildcard,$(OPENXLSX_DIR)/library/headers/*.hpp,$(AD_INCLUDE)/OpenXLSX)
	sed 's/headers/OpenXLSX/g' $(OPENXLSX_DIR)/library/OpenXLSX.hpp >$(AD_INCLUDE)/OpenXLSX/OpenXLSX.hpp
	printf "#pragma once\n#define OPENXLSX_EXPORT __attribute__((visibility(\"default\")))\n" >$(AD_INCLUDE)/OpenXLSX/OpenXLSX-Exports.hpp

test:
	$(MAKE) TEST=1

clean:
	rm -rf $(ACMACSD_ROOT)/build

help: help-vars
	printf "\nVariables:\n"
	printf "\tTEST=1 - run tests\n"
	printf "\n"
	printf "Targets:\n\tupdate-and-build\n\n"

$(patsubst %,$(AD_SOURCES)/%,$(PACKAGES)):
	$(call git_clone_or_pull,$@,$(GIT_URI))

$(AD_SHARE)/Makefile.%: | $(AD_SHARE)
	ln -svf $(abspath $(@F)) $@

.PHONY: update-and-build git-update make-dirs install-dependencies install-makefiles
.PHONY: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

# ======================================================================
### Local Variables:
### eval: (if (fboundp 'eu-rename-buffer) (eu-rename-buffer))
### End:

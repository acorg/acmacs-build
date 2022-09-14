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
  acmacs-tal \
  acmacs-py \
  acmacs-tree-maker \
  acmacs-whocc \
  acmacs-webserver

ifneq ($(shell uname -m),arm64)
  # mongodb interface is not build on M1
  PACKAGES_CXX_X86 = \
    acmacs-api
endif

#   signature-page

PACKAGES = \
  $(PACKAGES_CXX) \
  $(PACKAGES_CXX_X86) \
  ssm-report

#  acmacs.r discontinued on 2021-05-20

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

# ifneq ($(dir $(CURDIR)),$(realpath $(AD_SOURCES))/)
#   $(error acmacs-build must be placed in $(realpath $(AD_SOURCES)) (currently in $(CURDIR)))
# endif

update-and-build: make-installation-dirs
	$(MAKE) build-packages
.PHONY: update-and-build

install-makefiles: $(AD_SHARE)/Makefile.config
.PHONY: install-makefiles

update-packages: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

build-packages: make-installation-dirs install-dependencies update-packages install-makefiles
	$(MAKE) acmacs

acmacs:
	for package in $(PACKAGES); do \
	  echo Building $$package $(PACKAGE_TARGET); \
	  if [ $$package = "acmacs.r" ]; then \
	    $(MAKE) -C $(AD_SOURCES)/$$package MAKEFLAGS= $(PACKAGE_TARGET) || exit 1; \
	  else \
	    $(MAKE) -C $(AD_SOURCES)/$$package $(PACKAGE_TARGET) || exit 1; \
	  fi; \
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

install-dependencies: fmt xlnt mongocxx rapidjson range-v3 std_date pybind11 websocketpp asio
.PHONY: install-dependencies

#----------------------------------------------------------------------
mongocxx:
ifneq ($(shell uname -m),arm64)
	$(MAKE) -f Makefile.mongocxx
else
	$(warning mongocxx is NOT built on arm64)
endif

.PHONY: mongocxx

#----------------------------------------------------------------------
# 2021-10-10
PYBIND11_RELEASE = 2.8.0
# PYBIND11_RELEASE = 2.7.1 # 2021-08-03
# PYBIND11_RELEASE = 2.6.1 # 2020-11-12
PYBIND11_DIR = $(BUILD)/pybind11
PYBIND11_URL = "https://github.com/pybind/pybind11/archive/v$(PYBIND11_RELEASE).tar.gz"

pybind11: $(PYBIND11_DIR)/include/pybind11/pybind11.h
.PHONY: pybind11

$(PYBIND11_DIR)/include/pybind11/pybind11.h: $(BUILD)
	curl -sL -o $(BUILD)/pybind11-$(PYBIND11_RELEASE).tar.gz "$(PYBIND11_URL)"
	cd $(BUILD) && tar xzf pybind11-$(PYBIND11_RELEASE).tar.gz && ln -sf pybind11-$(PYBIND11_RELEASE) $(PYBIND11_DIR)
	$(call symbolic_link,$(PYBIND11_DIR)/include/pybind11,$(AD_INCLUDE)/pybind11)

#----------------------------------------------------------------------
# 2020-04-19
WEBSOCKETPP_RELEASE = 0.8.2
WEBSOCKETPP_PREFIX = $(BUILD)
WEBSOCKETPP_DIR = $(BUILD)/websocketpp
WEBSOCKETPP_URL = "https://github.com/zaphoyd/websocketpp/archive/refs/tags/$(WEBSOCKETPP_RELEASE).tar.gz"

websocketpp: $(AD_INCLUDE) $(BUILD)
	curl -sL -o $(BUILD)/websocketpp-$(WEBSOCKETPP_RELEASE).tar.gz "$(WEBSOCKETPP_URL)"
	cd $(BUILD) && tar xzf websocketpp-$(WEBSOCKETPP_RELEASE).tar.gz && ln -sf websocketpp-$(WEBSOCKETPP_RELEASE) $(WEBSOCKETPP_DIR)
	patch -d $(WEBSOCKETPP_DIR) -p1 <patches/websocketpp.diff
	$(call symbolic_link,$(WEBSOCKETPP_DIR)/websocketpp,$(AD_INCLUDE)/websocketpp)

.PHONY: websocketpp

#----------------------------------------------------------------------
# https://think-async.com/Asio/AsioStandalone.html
# https://github.com/chriskohlhoff/asio/
ASIO_TAG = asio-1-19-2			# 2021-10-08
# ASIO_TAG = asio-1-12-2
ASIO_DIR = $(BUILD)/asio

asio: $(AD_INCLUDE)
	$(call git_clone_tag,$(ASIO_DIR),https://github.com/chriskohlhoff,$(ASIO_TAG))
	$(call symbolic_link,$(ASIO_DIR)/asio/include/asio,$(AD_INCLUDE)/asio)
	$(call symbolic_link,$(ASIO_DIR)/asio/include/asio.hpp,$(AD_INCLUDE)/asio.hpp)

.PHONY: asio

#----------------------------------------------------------------------
RAPIDJSON_DIR = $(BUILD)/rapidjson

rapidjson: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(RAPIDJSON_DIR),https://github.com/Tencent)
	$(call symbolic_link,$(RAPIDJSON_DIR)/include/rapidjson,$(AD_INCLUDE)/rapidjson)

.PHONY: rapidjson

#----------------------------------------------------------------------
FMT_PREFIX = $(AD_ROOT)
FMT_DIR = $(BUILD)/fmt
# 2021-07-03
FMT_VERSION = 8.0.1
# FMT_VERSION = 7.1.3 # 2020-11-25
FMT_URL = "https://github.com/fmtlib/fmt/releases/download/$(FMT_VERSION)/fmt-$(FMT_VERSION).zip"
FMT_LIB_PATHNAME = $(FMT_PREFIX)/lib/$(call shared_lib_name,libfmt,$(FMT_VERSION))
FMT_INCLUDE_PATHNAME = $(AD_INCLUDE)/fmt/format.h
FMT_LOCAL_INCLUDE_PATHNAME = $(BUILD)/fmt/include/fmt/format.h

# https://github.com/fmtlib/fmt
fmt: $(FMT_LOCAL_INCLUDE_PATHNAME)
.PHONY: fmt
# $(FMT_LIB_PATHNAME): $(FMT_INCLUDE_PATHNAME)
# $(FMT_INCLUDE_PATHNAME): $(FMT_LOCAL_INCLUDE_PATHNAME)
# $(info > fmt $(FMT_LOCAL_INCLUDE_PATHNAME))

$(FMT_LOCAL_INCLUDE_PATHNAME): $(BUILD)
	rm -rf $(BUILD)/*fmt*
	curl -sL -o $(BUILD)/release-fmt.zip "$(FMT_URL)"
	cd $(BUILD) && unzip release-fmt.zip && ln -s fmt-* $(FMT_DIR)
	mkdir -p $(FMT_DIR)/build && \
	  cd $(FMT_DIR)/build && \
	  cmake -D CMAKE_COLOR_MAKEFILE=OFF -DFMT_TEST=OFF -DFMT_DOC=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=TRUE -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(FMT_PREFIX)" -DCMAKE_PREFIX_PATH="$(FMT_PREFIX)" .. && \
	  $(MAKE) install
	if [ "$$(uname)" = "Darwin" ]; then \
	  cd "$(FMT_PREFIX)/lib" || exit 1; \
	  for library in libfmt.$(FMT_VERSION)$(shared_lib_suffix); do \
	    /usr/bin/install_name_tool -id "$(FMT_PREFIX)/lib/$$library" "$$library" || exit 1; \
	  done; \
	fi
	$(call symbolic_link,$(FMT_DIR)/include/fmt,$(AD_INCLUDE)/fmt)

#----------------------------------------------------------------------
STD_DATE_DIR = $(BUILD)/date

std_date: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(STD_DATE_DIR),https://github.com/HowardHinnant)
	$(call symbolic_link,$(STD_DATE_DIR)/include/date,$(AD_INCLUDE)/date)

#----------------------------------------------------------------------
RANGEV3_DIR = $(BUILD)/range-v3

range-v3: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(RANGEV3_DIR),https://github.com/ericniebler)
	for dd in $(RANGEV3_DIR)/include/*; do if [ ! -d $(AD_INCLUDE)/$$(basename $$dd) ]; then ln -sfv $$dd $(AD_INCLUDE); fi; done

#----------------------------------------------------------------------
# https://github.com/kthohr/optim
OPTIM_DIR = $(BUILD)/optim
OPTIM_INCLUDES = -I$(AD_INCLUDE)/optim

optim: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(OPTIM_DIR),https://github.com/kthohr)
	cd $(OPTIM_DIR) && ./configure --header-only-version
	$(call symbolic_link,$(OPTIM_DIR)/header_only_version,$(AD_INCLUDE)/optim)

#----------------------------------------------------------------------
# https://github.com/tfussell/xlnt
# 2020-03-21
XLNT_RELEASE = 1.5.0
XLNT_PREFIX = $(AD_ROOT)
XLNT_DIR = $(BUILD)/xlnt
XLNT_URL = https://github.com/tfussell/xlnt/archive/v$(XLNT_RELEASE).tar.gz
XLNT_LIB_PATHNAME = $(AD_LIB)/libxlnt.$(XLNT_RELEASE).dylib
XLNT_INCLUDE_PATHNAME = $(XLNT_DIR)/include/xlnt/xlnt.hpp
ifeq ($(C),CLANG)
  XLNT_CXX_FLAGS = -Wno-suggest-override -Wno-suggest-destructor-override -Wno-extra-semi-stmt -Wno-implicit-int-float-conversion -Wno-missing-field-initializers
else
  XLNT_CXX_FLAGS = -Wno-missing-field-initializers
  # limits has to be included to compile xlnt/source/detail/number_format/number_formatter.cpp by g++-11 (xlnt 1.5.0 2021-05-27)
  ifeq ($(C),GCC11)
    XLNT_CXX_FLAGS += -include limits
  endif
endif
XLNT_CXX_FLAGS += -O3 $(MAVX) $(MTUNE)

xlnt: $(XLNT_LIB_PATHNAME)
$(XLNT_LIB_PATHNAME): $(XLNT_INCLUDE_PATHNAME)
.PHONY: xlnt

XLNT_CMAKE_CMD = cmake -D CMAKE_COLOR_MAKEFILE=OFF -D CMAKE_BUILD_TYPE=Release -D TESTS=OFF -D CMAKE_CXX_FLAGS_RELEASE="$(XLNT_CXX_FLAGS)" -D CMAKE_CXX_COMPILER="$(CXX)" -DCMAKE_INSTALL_PREFIX="$(XLNT_PREFIX)" -DCMAKE_PREFIX_PATH="$(XLNT_PREFIX)" ..

$(XLNT_INCLUDE_PATHNAME): $(BUILD)
	curl -sL -o $(BUILD)/xlnt-$(XLNT_RELEASE).tar.gz "$(XLNT_URL)"
	cd $(BUILD) && tar xzf xlnt-$(XLNT_RELEASE).tar.gz && ln -sf xlnt-$(XLNT_RELEASE) $(XLNT_DIR)
	@# third-party/libstudxml/version leads to build failure on macOS 10.14
	if [ -f $(XLNT_DIR)/third-party/libstudxml/version ]; then mv $(XLNT_DIR)/third-party/libstudxml/version $(XLNT_DIR)/third-party/libstudxml/version.orig; fi
	mkdir -p $(XLNT_DIR)/build && \
	  cd $(XLNT_DIR)/build && \
	  $(XLNT_CMAKE_CMD) && \
	  $(MAKE) install
ifeq ($(PLATFORM),darwin)
	/usr/bin/install_name_tool -id $(XLNT_LIB_PATHNAME) $(XLNT_LIB_PATHNAME)
else
	if [ ! -e $(AD_INCLUDE)/xlnt ] || [ -h $(AD_INCLUDE)/xlnt ]; then \
	  ln -sf $(XLNT_PREFIX)/include/xlnt $(AD_INCLUDE); \
	fi
endif

#----------------------------------------------------------------------
# https://github.com/troldal/OpenXLSX
OPENXLSX_PREFIX = $(AD_ROOT)
OPENXLSX_DIR = $(BUILD)/openxlsx
# OPENXLSX_INCLUDES = -I$(AD_INCLUDE)/openxlsx

openxlsx: $(AD_INCLUDE)
	$(call git_clone_or_pull,$(OPENXLSX_DIR),https://github.com/troldal)
	mkdir -p $(OPENXLSX_DIR)/build && \
	  cd $(OPENXLSX_DIR)/build && \
	  cmake -D CMAKE_COLOR_MAKEFILE=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX="$(OPENXLSX_PREFIX)" -DCMAKE_PREFIX_PATH="$(OPENXLSX_PREFIX)" .. && \
	  $(MAKE)
ifeq ($(PLATFORM),darwin)
	$(call install_program,$(OPENXLSX_DIR)/build/output/libOpenXLSX-shared.dylib,$(AD_LIB)/libOpenXLSX.dylib)
	/usr/bin/install_name_tool -id "$(AD_LIB)/libOpenXLSX.dylib" $(AD_LIB)/libOpenXLSX.dylib
else
	$(call install_program,$(OPENXLSX_DIR)/build/output/libOpenXLSX-shared.so,$(AD_LIB)/libOpenXLSX.so)
endif
	mkdir -p $(AD_INCLUDE)/OpenXLSX
	$(call symbolic_link_wildcard,$(OPENXLSX_DIR)/library/headers/*.hpp,$(AD_INCLUDE)/OpenXLSX)
	sed 's/headers/OpenXLSX/g' $(OPENXLSX_DIR)/library/OpenXLSX.hpp >$(AD_INCLUDE)/OpenXLSX/OpenXLSX.hpp
	printf "#pragma once\n#define OPENXLSX_EXPORT __attribute__((visibility(\"default\")))\n" >$(AD_INCLUDE)/OpenXLSX/OpenXLSX-Exports.hpp

#----------------------------------------------------------------------
# CHAISCRIPT_DIR = $(BUILD)/chaiscript
# CHAISCRIPT_VERSION = 6.1.0
# CHAISCRIPT_URL = "https://github.com/ChaiScript/ChaiScript/archive/v$(CHAISCRIPT_VERSION).tar.gz"

# # https://github.com/chaiscriptlib/chaiscript
# chaiscript: $(CHAISCRIPT_DIR)/include/chaiscript/chaiscript.hpp

# $(CHAISCRIPT_DIR)/include/chaiscript/chaiscript.hpp: $(BUILD)
# 	rm -rf $(BUILD)/*chaiscript*
# 	curl -sL -o $(BUILD)/release-chaiscript.tar.gz "$(CHAISCRIPT_URL)"
# 	cd $(BUILD) && tar xzf release-chaiscript.tar.gz && ln -s ChaiScript-* "$(CHAISCRIPT_DIR)"
# 	$(call symbolic_link,$(CHAISCRIPT_DIR)/include/chaiscript,$(AD_INCLUDE)/chaiscript)

#----------------------------------------------------------------------
test:
	$(MAKE) TEST=1

clean:
	rm -rf $(AD_BUILD)

help: help-vars
	printf "\nVariables:\n"
	printf "\tTEST=1 - run tests\n"
	printf "\n"
	printf "Targets:\n\tupdate-and-build\n\n"

$(patsubst %,$(AD_SOURCES)/%,$(PACKAGES)):
	$(call git_clone_or_pull,$@,$(GIT_URI))

$(AD_SHARE)/Makefile.%: | $(AD_SHARE)
	ln -svf $(abspath $(@F)) $@

.PHONY: $(patsubst %,$(AD_SOURCES)/%,$(PACKAGES))

# ======================================================================

# acmacs-build

Scripts to build Acmacs-D.

# Supported platforms

 - macOS 10.14.6 (with xcode 11.3.1) or later
 - Ubuntu Linux 20.04 (earlier versions are most probably good enough too)
 - Theoretcially any Linux distribution fulfilled requirements below.

# Requirements

- C++

  Acmacs-D is written in C++20 (state of Nov 2020). Either clang 13.x or g++ 11.x required.

  * macOS

     clang 13.0 can be installed using [homebrew](https://brew.sh):

     `brew install llvm libomp`

     Executables are expected to be in /usr/local/opt/llvm/bin

     Note for macOS 11.1 (Big Sur): if building fails with an error "clang++ is not able to compile a simple test program.",
     make a link MacOSX11.0.sdk to MacOSX11.1.sdk in /Library/Developer/CommandLineTools/SDKs

     If compilation failes at #include_next <stdlib.h>, download command line tools from
     https://developer.apple.com/download/more/
     Check: /Library/Developer/CommandLineTools/SDKs/

     Note for macOS 10.14 (Mojave): if building fails with an error "ld: unknown option: -platform_version",
     use the following command to enable newer ld (from xcode 11.3.1):

     `sudo xcode-select -S /Applications/Xcode.app/Contents/Developer`

  * Ubuntu Linux

    g++ 11.x can be installed using `apt-get install g++-11`

- All dependencies

  * macOS: `brew install armadillo cairo xz apache2 openssl r`


- Python

  Some of the Acmacs-D modules have python interface, Python 3.9 or later is required.
  As of Nov 2020 python interface is not maintained.

  * macOS: `brew install python3`
  * Ubuntu Linux: most probably comes with the system, otherwise `sudo apt install python3`

- R

  > ***acmacs.r discontinued on 2021-05-20***

  acmacs.r requires R 4.0+ (https://www.r-project.org) with Rcpp, testthat, roxygen2 packages.

  * macOS: `brew install r`
  * Ubuntu Linux: `sudo apt install r-base-core`

  `Rscript --no-save -e 'install.packages(c("Rcpp", "testthat", "roxygen2"),repos="http://cran.r-project.org")'`

- boost 1.68+

  * macOS: `brew install boost`
  * Ubuntu Linux: `sudo apt install libboost-dev libboost-date-time-dev`
    Note, make sure it's 1.68 or more recent. Otherwise install from sources.

- cairo

  * macOS: `brew install cairo`
  * Ubuntu Linux: `sudo apt install libcairo2-dev`

- xz

  * macOS: `brew install xz`
  * Ubuntu Linux: `sudo apt install xz-utils`

- bzip2

  * macOS: comes with the system (/usr/lib/libbz2.1.0.dylib)
  * Ubuntu: `sudo apt install libbz2-dev`

- GNU make 4.2

  * macOS: `brew install make` then use gmake
  * Ubuntu Linux: comes with the system

- [Unsued] GNU Guile 3.0

  * macOS: `brew install guile`
  * Ubuntu Linux: sudo apt install guile-3.0-dev

- CMake 3.2 or later

  * macOS: `brew install cmake`
  * Ubuntu Linux: `sudo apt install cmake`

- curl and libcurl

  * macOS: installed by default.
  * Ubuntu Linux: `sudo apt install libcurl4-openssl-dev`

- apache for mod-acmacs

  * macOS: `brew install apache2` (apache coming with the system does not allow building modules)
  * Ubuntu Linux: `sudo apt install apache2-dev`

- openssl for acmacs-webserver

  * macOS: `brew install openssl`

- ? [sassc](https://github.com/sass/sassc)

  Required by acmacs-api client

  * macOS: `brew install sassc`
  * Ubuntu Linux: install manually

- Other dependencies

  * macOS: `brew install libomp armadillo`

# Installation

Choose a directory where all the sources will be downloaded to and
programs will be built and installed. Set env variable ACMACSD\_ROOT
pointing to that directory, e.g. `ACMACSD_ROOT=$HOME/AD`

Clone this repository:

    mkdir -p $ACMACSD_ROOT/sources && git clone git@github.com:acorg/acmacs-build.git $ACMACSD_ROOT/sources/acmacs-build

Build acmacs-d

*Use GNU make*

    make -C $ACMACSD_ROOT/sources/acmacs-build -j8

# Installation (OBSOLETE)

Choose a directory where all the sources will be downloaded to and
programs will be built. Required space is 1.3Gb. It is called
\$SOURCE_DIR below.

Choose a directory where binaries, libraries and required data files
will be installed. It is called \$TARGET_DIR below.

\$SOURCE_DIR and \$TARGET_DIR can be the same. They are automatically created. Default values for them is ~/AD

Run:

`$ bin/install-acmacs-d --source $SOURCE_DIR --target $TARGET_DIR`

Program will check all the requirements mentioned above, downloads all
the required packages and build them. Approximate run time is 30
minutes.

Additional program arguments:

`--dev` - if you are developer, have github id and have write access
to acmacs-d repositories, sources are checked out using ssh.

`--dev-release` - for a developer, build using TT=R

`--acorg-only` - do not update boost, pybind11, etc.

`--tag` -  checkout specific tag

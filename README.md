# acmacs-build

Scripts to build Acmacs-D.

# Supported platforms

 - macOS 10.12+
 - Ubuntu Linux 16.04 or later
 - Theoretcially any Linux distribution fulfilled requirements below.

# Requirements

- C++

  Acmacs-D is written in C++17. Either llvm 7.x or gcc 8.x required.

  * macOS

     llvm 7.0 can be installed using [homebrew](https://brew.sh):

     `brew install llvm`

     Executables are expected to be in /usr/local/opt/llvm/bin

  * Ubuntu Linux

    gcc 8.x can be installed using `apt-get install gcc-8`

- Python

  Some of the Acmacs-D modules have python interface, Python 3.6.2 or later is required.

  * macOS: `brew install python3`
  * Ubuntu Linux: most probably comes with the system, otherwise `sudo apt install python3`

- R

  acmacs.r requires R 3.5+ (https://www.r-project.org) with Rcpp, testthat, roxygen2 packages.


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

  * macOS: `brew install make`
  * Ubuntu Linux: comes with the system

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

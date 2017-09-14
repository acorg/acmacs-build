# acmacs-build

Scripts to build Acmacs-D.

# Supported platforms

 - macOS 10.12 and 10.13
 - Ubuntu Linux 16.04 or later
 - Theoretcially any Linux distribution fulfilled requirements below.

# Requirements

- C++

  Acmacs-D is written in C++17. Either llvm 5.0 or gcc 7.1 required.

  * macOS

     llvm 5.0 can be installed using [homebrew](https://brew.sh):

     `brew install llvm`

     Executables are expected to be in /usr/local/opt/llvm/bin

  * Ubuntu Linux

    gcc 7.1 can be installed using `get-apt install gcc-7`

- Python

  Some of the Acmacs-D modules have python interface, Python 3.6.2 or later is required.

  * macOS

    `brew install python3`

  * Ubuntu Linux

    `apt-get install python3`

- xz

- CMake 3.2 or later

- curl

  Usually installed by default.

# Installation

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

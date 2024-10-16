# acmacs-build

Scripts to build Acmacs-D.

# Installation 16/10/2024

## Platform
  - macOS 14.7 (ARM 64)

## Requirements and their installation
nb: The specified versions are known to work, on 16/10/24 these were the default brew install versions

 - apache2 ~= 2.4
 - armadillo ~= 14.0
 - arpack ~= 3.9
 - boost ~= 1.86
 - cairo ~= 1.18
 - cmake ~= 3.30
 - libomp ~= 19.1
 - lld ~= 19.1
 - llvm ~= 19.1
 - make ~= 4.4 (called as gmake)
 - pyenv ~= 2.4
 - python ~= 3.13
 - sassc ~= 3.6
 - xcode ~= 16.0 (commandline tools)
 - xz ~= 5.6

 NB: instructions use non-specific versions on Brew install, in future software versions may need to be specified

 A number of these instructions involve modifying the .zshrc file, an example is included in the file "zshrc_info" in this directory

 ### Brew

To install brew follow the instructions on this page: [Homebrew installation page](https://brew.sh)

To install all dependencies (nb: some may already come with the system, brew will automatically skip them):
```
brew install apache2 armadillo arpack boost cairo cmake libomp lld llvm make pyenv sassc xz
```

 ### Python
This uses pyenv to install python.

To install pyenv run the following in terminal (nb: previous step includes pyenv install so if that has been run you can skip installing it again):
```
brew install pyenv
```
To finish setting up pyenv you need to modify your .zshrc (macOS) (a copy of zshrc)

To open .zshrc:
```
nano ~/.zshrc
```
Add the following lines then save and exit:
```
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
```
Then run:
```
source ~/.zshrc
```

To install and set python version:
```
pyenv install 3.13 && pyenv local 3.13
```

 ### .zshrc setup
 This package requires modification of the ~/.zshrc file.

 Run in command line:

 ```
 nano ~/.zshrc
 ```

 Add the lines from zshrc_info file, save and exit (nb. you may have already added pyenv ones above)

Run in commandline:
```
source ~/.zshrc
```

## ACMACS install

### Further set up
Having followed the above setup steps ACMACS build can now be installed

Choose a directory where all the sources will be downloaded to and programs will be built and installed and add it to your ~/.zshrc file as above

e.g. the example as per the zshrc_info example file:
```
export ACMACSD_ROOT="/Users/${USER}/Desktop/pipeline/AD"
```
Save and exit then run
```
source ~/.zshrc
```

Clone this repository using one of the following in commandline:
  If you have SSH set up for git:
  ```
  mkdir -p $ACMACSD_ROOT/sources && git clone git@github.com:acorg/acmacs-build.git $ACMACSD_ROOT/sources/acmacs-build
  ```
  if you do not have SSH set up for git:
  ```
  mkdir -p $ACMACSD_ROOT/sources && git clone https://github.com/acorg/acmacs-build $ACMACSD_ROOT/sources/acmacs-build
  ```

### Build with GNU make

Run the following in commandline
```
gmake -C $ACMACSD_ROOT/sources/acmacs-build -j8
```

### If installation should fail

Before rerunning the build script above, delete the following folders from AD (and empty them from the trashcan):
- build
- sources/acmacs-build/build
 


# OLD INSTRUCTIONS - included for linux
# Supported platforms (old)

 - macOS 10.14.6 (with xcode 11.3.1) or later
 - Ubuntu Linux 20.04 (earlier versions are most probably good enough too)
 - Theoretically any Linux distribution fulfilled requirements below.

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

***Use GNU make 4.x***

    gmake -C $ACMACSD_ROOT/sources/acmacs-build -j8

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

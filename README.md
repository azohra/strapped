# Strapped.sh

![logo](https://raw.githubusercontent.com/azohra/strapped/master/_static/img/logo-black.png)

[![Build Status](https://travis-ci.org/azohra/strapped.svg?branch=master)](https://travis-ci.org/azohra/strapped)

---

## Rationale


## Installation

To install strapped.sh, simply run this command:

```console
curl -s https://stay.strapped.sh | sh
```

Upgrading strapped.sh can be done by re-running the installation command above, or in the following way:

```console
strapped --upgrade
```

Here are all the command-line flags for strapped.sh (if that's your thing):

```console
Usage: strapped [flags]

flags:
  -u, --upgrade                  upgrade strapped to the latest version
  -v, --version                  print the current strapped version
  -a, --auto                     do not prompt for confirmation
  -y, --yml                      path to a valid strapped yml config [type: file/url]
  -s, --straps                   run a subset of your config. Comma seperated [type: string]
  -h, --help                     prints this message
```

## Usage

To strap your computer, simply run strapped and point to your strap config file with the `-y` or `--yml` flag

```console
strapped -y my_config.yml
```

You can even pass the URL to a config file!

```console
strapped -y https://www.example.com/my_config.yml
```

### About Configuration Files

Configuration files are used as a blueprint for your computer's configuration. These files are composed of various `straps`,
which each serve different purposes. Straps themselves are implemented by `routines` that form the functionality of the strap.

Lets take a look at a config file:

```yml
# You must specify the repo that strapped.sh will source its straps from
# this can be in the form of a URL or a link to a local repo.
# By default, straps will be sourced from this repository, but you can link
# strapped to any repo that implements strapped functionality.
strapped:
  repo: https://raw.githubusercontent.com/azohra/strapped/master/straps

# Use the brew strap (specifically v0.1.0) to install tap taps and install packages
brew:
  version: v0.1.0
  taps:
    - { name: homebrew/core }
  packages:
    - { name: terraform }
  casks:
    - { name: visual-studio-code }

# Use the git strap to clone repos into a specific directory.
# Since we have not specified a version it will search for the 
# latest version in the repo
git:
  clone:
    - { repo: git@github.com:kelseyhightower/nocode.git, folder: ~/repos }

# Install vscode extensions using latest version of the visual_studio_code strap
visual_studio_code:
  extensions:
    - { name: PKief.material-icon-theme }
```

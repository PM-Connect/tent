CHANGELOG
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2019-10-23 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.4.0)](https://travis-ci.org/PM-Connect/tent)
## Added
- Added the ability to build specific deployments using the `-deployment=` flag on the `build` command.
- Added the ability to build specific deployment builds using the `-build=` flag on the `build` command.

## [1.3.2] - 2019-09-16 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.3.2)](https://travis-ci.org/PM-Connect/tent)
## Fixed
- Fixed generation of docker command to quote only build arg values to ensure correct functionality.

## [1.3.1] - 2019-09-12 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.3.1)](https://travis-ci.org/PM-Connect/tent)
## Fixed
- Fixed generation of docker command to quote argument values to ensure correct functionality.

## [1.3.0] - 2019-07-19 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.3.0)](https://travis-ci.org/PM-Connect/tent)
## Added
- Added the ability to retry failed http requests when talking to nomad.

## [1.2.0] - 2019-05-21 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.2.0)](https://travis-ci.org/PM-Connect/tent)
## Added
- Added support for dockerfile build args using the `build_args` map within the builds section of the configuration.

## [1.1.0] - 2019-05-15 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.1.0)](https://travis-ci.org/PM-Connect/tent)
## Changed
- Allowed failed requests during monitoring of deployment to retry up to 5 times.

## [1.0.8] - 2019-04-17 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.8)](https://travis-ci.org/PM-Connect/tent)
## Changed
- Ensuring branch deploy tags are lowercase for compatibility with AWS container registry.

## [1.0.7] - 2019-02-06 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.7)](https://travis-ci.org/PM-Connect/tent)
## Changed
- Reworked nomad client to use the official go api package provided by hashicorp.

## [1.0.6] - 2019-01-17 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.6)](https://travis-ci.org/PM-Connect/tent)
## Fixed
- Fixed issue with docker image tags containing uppercase characters and repositories only allowing lower case. This caused an issue with nomad/aws ecr when trying to download an image with uppercase characters.

## [1.0.5] - 2018-11-26 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.5)](https://travis-ci.org/PM-Connect/tent)
## Fixed
- Fixed checking of nomad parsing and now checking for status codes less than 200 or greater than 299, instead of erroring on 200's.

## [1.0.4] - 2018-11-26 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.4)](https://travis-ci.org/PM-Connect/tent)
## Added
- Added more debug output when running in verbose mode to show the json document that is generated from the hcl nomad file.
## Changed
- Changed handling and detection of errors when parsing the nomad hcl file. There should now be less chance of a parse error going undetected.

## [1.0.3] - 2018-10-23 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.3)](https://travis-ci.org/PM-Connect/tent)
### Fixed
- Fixed issue where nomad deployments would fail but tent would exit with success.

## [1.0.2] - 2018-10-08 [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.2)](https://travis-ci.org/PM-Connect/tent)
### Fixed
- Fixed issue where providing an invalid environment name when running deploy/destroy continued as normal instead or erroring.
- Fixed issue when attempting to deploy nomad batch jobs (these do not return an `EvalID`).

## 1.0.0 Initial Release [![Build Status](https://travis-ci.org/PM-Connect/tent.svg?branch=v1.0.0)](https://travis-ci.org/PM-Connect/tent)

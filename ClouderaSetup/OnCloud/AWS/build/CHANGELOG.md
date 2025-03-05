# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2025-02-28

### Added
- Enabled HTTPS/SSL for Keycloak server deployment with Route53 domain integration.
- Enabled S3 bucket lifecycle policy for logs cleanup.
- Added a new parameter vc_tier for CDE service virtual cluster deployment.
- Added a new folder for AWS_Enhancements.

### Changed
- Updated the Dockerfile i.e base image, Terraform, Ansible, Python3, Quickstart versions, layering optimizations.
- Updated Readme documentations.
- Updated sg_name logic for keycloak deployment.
- Enhanced logging statements.

### Fixed
- Fixed CML deployment definition to include only one of default_settings and cpu_settings.

## [2.3.2] - 2025-02-06

### Changed
- Changed the CML service parameters.

### Fixed
- Fixed CML service deployment failure due to parameter definition changes in new CML runtime version.

## [2.3.1] - 2025-01-03

### Changed
- Updated the CDW service parameters as per new CDPCLI version

### Fixed
- Fixed CDW service deployment failure due to parameter changes in new CDPCLI version

## [2.3.0] - 2024-12-30

### Added
- Added a new parameter of datalake_version
- Added a precheck for workshop name length

### Fixed
- Updated the enable_gpu parameter to accept only boolean values


## [2.2.0] - 2024-12-02

### Changed
- Renamed and restructured repo folders
- Updated Keycloak SSO URL as per CDP region
- Updated Readme files

### Added
- Added new readme files for newly created folders


## [2.1.0] - 2024-11-15

### Changed
- Updated code to parameterize the cdp-tf-quickstart version while building the Docker image, could be passed externally as docker build-args

## [2.0.0] - 2024-10-09

### Added
- New feature to parameterise the CDP quota for user,group and identity provider.
  

### Changed
- Changed the authentication method for AWS and CDP
- AWS_KEY_PAIR is now an optional parameter

### Removed
- Removed the need of passing access key and secret key for AWS and CDP via config file.
- Removed the need of Keycloak ServerName and SG Name in config file.



## [1.0.0] - 2024-08-02

### Added
- New feature to parameterise the size of Virtual Warehouses provisioned.
- New feature to parameterise instance type, min and max instance count while activating CDE service and spark version for virtual cluster

### Changed

### Fixed

### Removed

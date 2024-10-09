# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

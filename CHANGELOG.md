# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.0.0-pre3] - 2018-11-08

### Added
- rake task `vm:nobuild` to provision VMs without building/downloading ISOs

### Changed
- Change OS ISO staging directory from `download/isos/` to `isos/`
- Update RVM Ruby to 2.4.4

### Removed
- Unused rake tasks


## [1.0.0-pre2] - 2018-07-26
Cleanups

### Added
- new `clone` stage added between `setup` and `build`
- Workaround for simp-core#522 silliness
  - (`rm rpm_docker/metadata.yml` in `vagrant/build.d/20_build_iso.sh`)

### Changed
- Scripts in `*.d/` dirs run in order
- RVM install tries another gpg key servers if the first one fails
- Documented customization options in README.md
- Better shellcheck coverage in run_tasks.sh

## [1.0.0-pre1] - 2018-03-24
Rewrote everything to use documented SIMP build process and template CI runners

### Added
- ISO is downloaded and built automatically (by default)
  - Uses rake beaker:suites[rpm_docker] build method
- `scripts/` directory
- README, CHANGELOG, LICENSE
- environment variables:
  - modify vagrant provisioning
  - pass-through support for build-relevant environment variables
- rudimentary ISO-downloading (using aria2c for speed)
- Installs docker

### Changed
- Complete re-write for SIMP 6.X

## [0.2.0] - 2016-03-03
(SIMP-862) Build a vbox for CI perfomance tests

### Added
- `.gitignore`
- haveged (helps the VM keep enough entropy for the many crypto-related tasks)

### Changed
- `/ISO` synced folder
- RVM Ruby version is now 1.9.3

### Removed
- `/vagrant`

## [0.1.0] - 2015-11-19
Made a Vagrantfile to help docs folks build SIMP ISOs on their MacBooks

### Added
- `Vagrantfile`

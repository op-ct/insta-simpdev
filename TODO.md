
## locations

- [ ] where to find ISOs
  - [x] default
  - [x] ENV vars
    - CENTOS_7_ISO_URL=http://isoredirect.centos.org/centos/7/isos/x86_64/
    - CENTOS_6_ISO_URL
    - CENTOS_7_DVD=CentOS-7-x86_64-DVD-1708.iso
    - CENTOS_6_DVD1
    - CENTOS_6_DVD2
- [ ] where to get OLD ISOs
  - [ ] default
  - [ ] env var
- [ ] How do we receive refs?




## Usage

`rake build:get_iso[CentOS,7,x86_64]  # defaults to CentOS,7,x86_64`

## TODO

<!-- not yet:
 __ - unless I already have access to ISO
  - download them
-->

- build ISO
  - [ ] fetch `simp-core` repo @ ref
  - __ [optional]:
    - ___ fetch `Puppetfile` from repo @ ref
    - ___ modify `Puppetfile`
  - [ ] deps checkout
  - [ ] ensure ISO is in `ISO/`
  - build:auto
    - default settings: `SIMP_BUILD_docs=no SIMP_ENV_NO_SELINUX_DEPS=no BEAKER_destroy=yes`
- build vagrant
  - [ ] checkout simp-packer repo @ ref

- BOXES NEEDED:
  - [ ] empty box (no need to rebuild)
  - [ ] Puppet master
    - [ ] BEFORE simp-config
    - [ ] AFTER simp-config
  - [ ] Puppet agent



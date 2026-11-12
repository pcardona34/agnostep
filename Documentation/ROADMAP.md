# Roadmap of the next relase: 4.0.0

Not yet defined: see below "Posponed"

# Roadmap of the building release 3.0.0

We list here things to be done to achieve this release:

Publishing all the new modules: work in progress.

Localization:
- [ ] French interface provided for all Core Apps and Native apps.
  - [x] Native apps: AgnostepManager, Birthday, Dico, Launcher  
Meteo, Mixer, OpenDisk, Pass, Printer, SaveLink, ScreenLock,  
Sound, Updater, UpMem.
  - [x] Help bundles of the Native Apps  all translated to French.
  - [ ] Several FORKED Core, Extra and Devel Apps:
    - [ ] Change the method: real forks and PR then...
    - [ ] Chess, FlexiSheet, Gemas, Gorm, Grr, HelpViewer, Innerspace,  
Ink, Player, PRICE, ScanImage, StepSync, SystemPreferences. 

  - [ ] Documentation: namely README, INSTALL translated too.

> [!Note]
> Of course, if some contributor wish to add its language, he/she is welcome.

## Testing

- [ ] All tests with a fresh install on a Pi 500.
- [ ] All tests with a new amd-64 Debian netinstall iso (vm).
- [ ] All tests with an Intel MacBook.

## Create and publish the new Release

- [ ] Merge with main branch of agnostep-dekstop and tag SOURCE Beta release: 3.0.0 will begin a new cycle of tests.
- [ ] RC release...

> [!WARNING]
> Due to limitation size, I cannot publish ISOs nor SD-Card images on Github.
> If you could help on this, let me know.

---

# POSTPONED

I.e. to a future release (target: 3.X or 4.0.0?)

## Enhancing some apps:

- [ ] Add plain text search from a pdf document
- [ ] Sound.app and Mixer.app: dynamic guess of the sound card and the Volume controller

## New apps

- [ ] Try to build [Oolite](https://github.com/OoliteProject/oolite) depending on a modern runtime.

## Native applications to create

- [ ] Reader.app - A GNUstep epub and comics reader.
- [ ] Publish.app - A GNUstep publishing application based on pandoc: edit with markdown (see new StepDown by gcasa) and export to epub/pdf.

## Universal Package for Installer

The idea is to propose an Universal way of installing a GNUstep app...

- [ ] Exchange with GNUstep community (all the projects to be concerned)
- [ ] Specs
- [ ] First Universal Package
- [ ] Adapt Installer.app / agnostep-apps-manager to handle those UPs.

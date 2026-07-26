# Roadmap of the next release: 3

## GNUstep Applications to add / enhance

- [ ] Add application: LUserNET
- [ ] New release of SimpleAgenda: 0.48  
  https://github.com/poroussel/simpleagenda/archive/refs/tags/v0.48.tar.gz
- [ ] Try to build [Oolite](https://github.com/OoliteProject/oolite) depending on modern runtime: see below.

## Native applications to create

> [!NOTE]
> The community seems to wait for the [Ladybug](https://ladybird.org/) project to accomplish: Alpha tagetted in 2026.
> But not yet available.

- [ ] Surf.app - A new Web Browser based on XEmbedded [Surf](https://surf.suckless.org/)
- [ ] Read.app - A GNUstep epub and comics reader.
- [ ] Publish.app - A GNUstep publishing application based on pandoc: edit with markdown (see above) and export to epub/pdf.

## Window Manager and modern runtime

- [ ] A new Window Manager with better handling of the Key Application. Until now, WindowMaker looses the key app and often displays several menus on top of each other.
    - [ ] Maybe a fork of WindowMaker?
    - [ ] Maybe another WM like [uroswm](https://github.com/AlessandroSangiuliano/uroswm) by Alessandro Sangiuliano? That could involve a radical change on GNUstep runtime (see below).
- [ ] If needed, a try to build a modern GNUstep with libobjc2 from sources on Debian! 


## Enhancing some apps:

- [x] Pass.app (0.2): add Edit button and action on the list Panel after a search.
- [ ] Sound.app and Mixer.app: dynamic guess of the sound card and the Volume controller
- [ ] Launcher.app (not depending on GWorkspace).
- [ ] Maybe extending supported languages within Gemas Editor: markdown, bash.

## L18N: French target

- [ ] French interface provided for all Core Apps and Native apps.
  - [x] AgnostepManager: UI and Info Panel
  - [x] Birthday: UI and Info Panel.
  - [x] Dico: UI.
  - [x] Launcher: UI and Info Panel.
  - [x] Meteo: UI and Info Panel.
- [ ] Help bundles all translated to French.
  - [x] AgnostepManager: French help bundle
  - [x] Birthday: French help bundle.
  - [x] Launcher: French help bundle.
- [ ] Documentation: namely README, INSTALL translated too.

> [!Note]
> Of course, if some contributor wish to add its language, he/she is welcome.

## Universal Package for Installer

The idea is to propose an Universal way of installing a GNUstep app...

- [ ] Exchange with GNUstep community (all the projects to be concerned)
- [ ] Specs
- [ ] First Universal Package
- [ ] Adapt Installer.app to handle those UPs.

## Testing

- [ ] All tests with a fresh install on a Pi 500.
- [ ] All tests with a new amd-64 Debian netinstall iso.
- [ ] All tests with an Intel MacBook.

## Create and publish the new Release

- [ ] SOURCE Beta release: 3.0.0 will begin a new cycle of tests.
- [ ] RC release...

> [!WARNING]
> Due to limitation size, I cannot publish ISOs nor SD-Card images on Github.
> If you could help on this, let me know.

# AGNoStep - agnostic GNUstep Desktop

## About dev releases (Beta Status)

All dev release are for my convenience.
Do not use them if you are not a developer understanding the code used.
Do not try nor report any issue until a release is tagged Stable.

## Changes

### Changes of the Release Beta 3.0.0

- Pass.app: release 0.2. Added Edit button and action to the List Panel.

### Changes of the Release Candidate 2.0.4

- Tweaking alsa test on pi 500.
- Updating documentation.

### Changes of the Release Beta 2.0.3

- This release ends the tests cycle on my laptop (MBPRO Intel model:6,2)
  - Battery plugging / unplugging is ok
  - Specific installation scripts and resources in RESOURCES/MACSET: keyboard, backlight, sound.
  - Detection at first stage (prep).
- Known issue: neither Mixer.app nor VolumeControl.app were able to adjust volume.

### Changes of the Release Beta 2.0.2

- This is an intermediate stage while testing on amd64 laptop, namely MBPro Intel: do not use yet.

### Changes of the Release Beta 2.0.1

- This release achieves 2.0.0 beta development on pi 500. Tests on amd64 and laptop yet to be done.
- Fixed several critic install issues on a fresh install.
- Dispatched agnostep main script to **agnowiz.sh** (core installation) and to **agnostep.sh** (applications manager).
- Tested all stages to get a strongest installation process.
- Updated install documentation.

### Changes of the Release Beta 2.0.0

This is a **major release** with many changes and improvements.

- Introduced new Native Agnostep in purpose Applications collection for a better Desktop and GNUstep experience: see [CORE_APPS](CORE_APPS.md) for the details: read section "Native GNUstep in purpose apps". 
- Some dockapps like `wmtext` were removed in favour of the new equivalent GNUstep applications: see *Meteo.app*, *UpMem.app*, *Updater.app* and *Birthday.app*. 
- Simplified desktop flavours to retain a single one, with Clip and Dock of WindowMaker: so the *Conky* flavour is deprecated since 2.0.0 release.
- Now, the Desktop can be installed without a theme (i.e. the default theme will be GNUstep). You can choose AGNOSTEP theme from the main menu of AgnostepManager then.
- **Settings** stage is more consistent: by example, the *laptop* test has been removed from theming to be executed while setting the X session...
- Thanks to the enhancements of *HelpViewer*, Help Folder has been removed because now all the help bundles will be installed at compile time for each relevant application: read [HELP](HELP.md) to search a particular help topic. This closes issue #9.
- Deprecated Subcategories in the Applications folder have been removed. We get back a flat organization which is more efficient with built-in first-letter filter. **Launcher** app is a shortcut to open the Applications folder.
- Theming has been provided again with the core repo of the project: [agnostep-theme](../../../../agnostep-theme) has been simplifed to collect only ARTS backup.
- A new collection of wallpapers for the rotate utility has been added: *Mallorca*.
- Now, the wallpaper will be handled by the Window Manager instead of GWorkspace. This choice permitted namely to fix issue #14, also thanks to the latest code of GWorkspace updated by Riccardo Mottola. 

> [!TIP]
> Agnostep Desktop will provide help within GWorkspace, Birthday, Launcher, OpenDisk, Pass, Printer, ScreenLock, SaveLink, Sound, Updater... Read [HELP](HELP.md).


### Changes of the Release Candidate 1.0.0 - RC 7.0

- Completed SaveLink with Help and French translation (Help too and interface).
- Added Dico: a Lookup French Dictionary app and service from the DVLF of the University of Chicago.
- Focus issues with Window Maker are not yet fixed.

### Changes of the Release Candidate 1.0.0 - RC 6.0

- Added ExitSession app.
- See also important changes within agnostep-theme 0.9.7 and the way the session is managed.

### Changes of the Release Candidate 1.0.0 - RC 5.0

- Added new Utilities applications: SaveLink (Internet Shortcuts Manger) and TestCuckoo (a simple test of sound).
- Added new Wrappers: Scribus, Xpdf.

### Changes of the Release Candidate 1.0.0 - RC 4.4

- Removed the branch 'app-wrapper-open-url'. It was need to fix an issue with NSSound, fixed within master of libs-gui. The openURLService is still working as expected.

### Changes of the Release Candidate 1.0.0 - RC 4.3

- Added ScreenLock wrapper for xtrlock.
- Fixed the issue "Nano seems to have hung": now, we can edit several files simultaneously with Nano.app.
- Improved all wrappers using an xterm call with pidwait.
- Improved .nanorc.

### Changes of the Release Candidate 1.0.0 - RC 4.2

Back to pi 500 test platform.

- Simplified pre-install stage.
- Updated Tests protocol.
- Added Alsa test within 1_prep.sh: fixed the 'Cuckoo' issue - i.e. the need to rebuild libs-gnustep-gui to handle wav sounds with NSSound.
- Fixed - I hope so - Firefox ever recreating Downloads folder in French l10n.
- Fixed the omitted sanity check after gnustep-libs build.
- Added a Helper within Web browsers wrappers (Firefox and Chromium) to handle Internet Shortcuts (.url).
- Populated Favorites folder with some Internet Shortcuts.
- Extended types to be edited by Nano.app.
- Added item "Web" in the Wrappers menu from AgnostepManager.

### Changes of the Release Candidate 1.0.0 - RC 4.1

- Fixed an issue in Firefox-esr Wrapper installation.

### Changes of the Release Candidate 1.0.0 - RC 4

This release follows the serie of tests on a x86_64 architecture.
Namely on a VM within Virtualbox.

- Dispatched the Help resources on a new separate repo: [agnostep-help](../../../../agnostep-help)
- Fixed an issue with Firefox-esr default profile.
- Added new items to `AgnostepManager`:
  - Meteo: allow to reset the coordinates (dep: agnostep-theme)
  - Help: fetch and install the localized .help bundles.
  - Update: perform a pull from origin main.
- Many other changes were done on the [agnostep-theme](../../../../agnostep-theme) repo.

### Changes of the Release Candidate 1.0.0 - RC 3

This release begins the serie of tests on a x86_64 architecture.
First tests with Qemu/Kvm: bad graphic rendering.
We will move the future tests to virtualbox.

- Dispatched prep and core because prep needs often to log out to apply the new settings.
- Fixed an issue with `lo.sh`: substituted `pkill` to `killall`.
- Added console-setup into prep stage.
- Removed X keyboard hack from 6_user_settings.sh
- Fixed an issue in Firefox wrapper installer: we must use 'esr' release now.

### Changes of the Release Candidate 1.0.0 - RC 2

- Enhanced fetching to avoid a wget fail issue with a more strong fetch function: see install/SCRIPTS/fetcher.sh.
- Propagate the use of fetch there were simple wget use: many scripts concerned.

### Changes of the Release Candidate 1.0.0 - RC 1

This release begins the serie of tests on a pi 500.

- Fixed a path issue in Xorg Hack and moved it to 6_user_settings.sh.
- Removed obsolete code about logs in 6_user_settings.sh.
- Fixed an ambiguous grep on release info. Now right info is written in release.info.
- Updated messages info at the end of user settings.
- Auto-reboot if a pi 500 to apply Xorg Hack.
- Install agnostep CLI: before was done by agnostep-theme, which was inconsistent.

### Changes of the dev release 0.9.9.4 - beta

This release ends the serie of tests on a pi 400.

- AgnostepManager.app: Fixed a path issue in AgnostepManager and in Recover: auto-repair was successfully tested then.

### Changes of the dev release 0.9.9.3 - beta

- Added more tests items: unsetting the theme; listening to cuckoo.
- Added Locales and Timezone settings.
- Added a timer and logout even in a shell script.
- Tweaked better installation presentation with Frameworks and apps.
- Fixed some issues within Frameworks building.

### Changes of the dev release 0.9.9.2 - beta

- Added wrapper Abiword.app
- More grained tests protocol in Documentation/TESTS.md
- Fixed missing dep: 'gv' needed for printing and preview. 

### Changes of the dev release 0.9.9.1 - beta

- Set Firefox profile. Remove -esr.
- Fix path issue reading release from `agnostep` cli tool.
- Add option `--am` to launch 'AgnosteManager' from `agnostep` cli tool.

### Changes of the dev release 0.9.9.0 - beta

This is a main dev release with many changes and improvements:

- Changes to allow new AGNOSTEP-theme feature: wallpaper rotate.
- Changes to comply with the subcategories in the 'Applications' folder.
- Testing and improvements with AgnostepManager, the menu of installation tasks.
- Mostly all the scripts and functions were improved due to heavy testing and to the changes above. Better way to find installed apps, even in subfolders, and cleaner removing too.
- Documentation updated to reflect Applications subcategories, namely new 'Core Apps' and 'Utilities' folder.
- New wrappers: AgnostepManager, Printer, RPI_TOOLS/Rpi-Bookshelf.
- New Resources to handle the case of pi500 and vc4 driver (still to be tested and validated).
- Updating Xresources (XTerm) with no conflict with AGNOSTEP-theme.
- New way to log all the scripts in a single consistent journal in /var/log : see log.sh.
- Better nano config within Nano wrapper to handle more common shortkeys.

### Changes of the dev release 0.9.8.4 - Beta

- Added ftp (fixed webservices fetching issue); fixed conf issue with quilt (solved popplerkit install).

### Changes of the dev release 0.9.8.3 - Beta

- Fixing many issues (typos, path) while testing on new fresh platfom. 

### Changes of the dev release 0.9.8.2 - Beta

- New: main `agnostep.sh` script at the top level to provide a general menu for install core, apps, and so on.
- New: `remove.sh` script to handle removing of a selected app: to be continued.

### Changes of the dev release 0.9.8.1 - Beta

- Fix Service openURL: (to be installed after Firefox wrapper: done)
- New Wrapper: Nano to handle .sh .md .path
- Complete reorganization of stage 5: see 5_install_core_apps.sh
- Bash Dialog menus to handle installation of extra apps, devel, games, wrappers...
- In Wrappers: choice between Chromium.app and Firefox.app
- New app in devel: Emacs built '--with-ns' build arg.
- New apps in Extra: Affiche, Cenon, Zipper. DictionaryReader (from etoile) replaces Dictionary (from GSDE). Preview replaces ImageViewer.

### Changes of the dev release 0.9.8 - Beta

- Updater: fixing sudo issues with Updater notifications witin 5c5 flavour. New wrapper: Upgrade.app.
- GWorkspace: Patch to fix L18N issue of 'Downloads' folder in Franch context.
- New way to install wrappers (first stage. To be continued) 
- Misc: updating deps list.

### Changes of the dev release 0.9.7 - Beta

- Using 'gnustep-config' and 'GNUstep.conf' to retrieve GNUstep env.
- AGNOSTEP theme now reached 0.5 stable release. But will go soon on new Beta to add more features.

### Changes of the dev release 0.9.6

- Cleaning obsolete things.

### Changes of the dev release 0.9.5

Some issues fixed: better integration of agnostep-theme: dockapp 'wminfo' will install now within 'c5c' flavour of the theme.

### Changes of the dev release 0.9.4

The new 0.9.4 release introduces a major change: now the theme will be available on its own at [agnostep-theme](https://github.com/pcardona/agnostep-theme).
The new theme will also provide two flavours: 'conky' and 'c5c': see the them site to know more about this.
Of course, AGNoStep Desktop will provide an integrated way of smoothly install it within the Desktop.
The User may also choose to not install the theme: so the default theme would be GNUstep, not AGNOSTEP.

Also new apps are available. See below the detailed list.

### Changes of the dev relase 0.9.3

Since 0.9.3 release, AGNoStep should run on all possible hardware, comprising all the Raspberry Pi's
known to work previously on the PiSiN project, mutatis mutandis. 
See the [HCL](HCL) file to know how to report a successful installation on your hardware.

## Removed

- Rpinters.app: obsolete

## INFO

- We started from the release 0.8.3 and then 0.8.6 of PiSiN to make it agnostic. Many changes in the meanwhile.

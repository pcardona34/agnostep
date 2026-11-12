# AGNoStep Overview

## Goal

AGNoStep project tries to provide a way to install a GNUstep compliant Desktop from sources, i.e. from the most recent commits, but with ease, thanks to its wizard.

It provides also **modules** to complete the Core Desktop as explained in the [README](../README.md).

It is provided under the [MIT License](../LICENSE).

# What means AGNoStep

It means an Agnostic GNUstep Desktop for All. 

- Read [RELEASE](RELEASE.md) to know the current status.
- See [CHANGES](CHANGES.md) to read the details of the latest changes.
- Read [BRIEF](BRIEF.md) to get a kind of FAQ about AGNoStep.

## What is a GNUstep compliant Desktop

- GNUstep is a free, open-source development environment that provides a **framework** for building cross-platform applications using the **Objective-C** programming language: see [GNUstep.org](https://www.gnustep.org). 
- So a compliant GNUstep system must be set on the top of a **complete GNUstep System**.  
Thanks to this framework, we can build all the pieces of software together to provide the User experience. 

Namely, the Core Desktop provides:

- A complete [Workspace](http://toastytech.com/guis/openstep.html) inherited from the famous NeXT/OPENSTEP specifications.  
See [agnostep-desktop](../../../../agnostep-desktop) module for details and technical notes about the Core Desktop.
- A set of useful **applications**: contacts, agenda, mail user agent, Text editor, Terminal... and a collection of native Apps and Tools.  
See [agnostep-apps-manager](../../../../agnostep-apps-manager) and [agnostep-applications](../../../../agnostep-applications).

## What does mean an Agnostic GNUstep Desktop?

- **Agnostic**: means the Core Desktop and then the GNUstep Applications can be installed on many hardwares because they both are built from sources.  
It is like the [Ports Collections](https://www.lpthe.jussieu.fr/~talon/freebsdports.html) method on a BSD System.
- As **Debian** is until now the first target and the tested underlying operating system, where you can install Debian, you are able to install then AGNoStep.
- See the [HARDWARE COMPATIBILY LIST](HCL.md) for my hardware testing list. Of course, it is not exhaustive.

> [!WARNING] 
> To become fully agnostic, we should have made dependencies lists available for Redhat like systems too, LFS or BSD. If you intend doing so, please, submit PR request to make this effective and available for others.

>[!IMPORTANT]
> The graphic target is Xorg/X11 because we use Xembed feature within several apps.
> If you are looking for a Wayland project, consider using another Desktop Core, like [Ambrosia](https://github.com/DMJC/ambrosia).

## An expandable collection of applications

To add more applications, you must use [agnostep-apps-manager](../../../../agnostep-apps-manager).

## At the Edge and with consistency

- AGNoStep tries to follow the most recent fixes and patches provided by the GNUstep community. 
- So most of the applications are built from the latest *subversion* or *git* repos.
- All known issues are discussed with the community, so Agnostep contributes to make the ecosystem better. Its purpose is to be consistent with all the work done by the community.
- The Core Desktop will provide two flavours at first installation stage:
  - One called *Classic* with GNUstep **Legacy**, whitch goal is stability and daily use; 
  - And another one called *Modern* with **libobjc2**, to enable testing of modern apps like *gnustep-windowmanager* or *apps-dock*. 

## About Theming

You can install the Core Desktop with the default GNUstep theme or choose the in purpose AGNOSTEP theming module to customize it: see [agnoste-theme](../../../../agnostep-theme).

You may also set a collection of walpapers thanks to [agnostep-wall](../../../../agnostep-wall) module.

## Available for Raspberry Pi's too

- Following the Agnostic principle, as AGNoStep was forked from the deprecated [PiSiN](https://github.com/pcardona34/pi-step-initiative) project, you can still install it on a Rasbberry Pi.
 Moreover, all the previous releases were firstly developed on a pi 400 and the latest releases, since 2.0.0, were developed on a pi 500.
 If a RPI is detected, some settings will be adapted to it. Of course, you must use a specific SD Card with the RPI OS Lite: see INSTALL section of [agnostep-desktop](../../../../agnostep-desktop) module. 

## How to install the whole project

From [README](../README.md) list of modules, get every one and follow their respective installation instructions.

A consistent way is to install:
1. agnostep-destop
1. agnostep-theme (optional)
1. agnostep-wall (optional)
1. agnostep-apps-manager (recommended)

## What next?

See [Roadmap of next release](ROADMAP.md)...

## Thanks and tributes

See [Thanks and tributes](THANKS.md)

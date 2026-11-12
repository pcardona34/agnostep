# Brief about Agnostep Project

This is a kind of FAQ.

## Operating system

- What operating system is targetted or much easy to install on?
> Debian stable (Trixie)

## Architecture

- What architectures are targetted? 
> All where Debian could be installed

## Display Protocol

- What is the display protocol targetted?
> Xorg

## Window manager

- What window manager is required?
> Window Maker 0.96.0 installed from debian package.
> Modern flavour enables to test gnustep-windowmanager (by Joe Maloney) as an amternative.

## Workspace manager?

- What is the Workspace manager?
> GWorkspace (1.1.0)
> Modern Flavour enables  to test Finder (FileViewer) by Greg Casamento.

## What is the global style?

- What is the global style?
> NeXT like within Classic Flavour.
> MacOS like within Modern Flavour.

## GNUstep system

- Is the GNUstep system installed native or forked?
> It is the Native GNUstep system from official github repository.

## Objective-C and runtime

- Does the GNUstep system installed complies with libojc2 or legacy objective-C?
> It is the Legacy runtime within Legacy flavour.
> The Libobjc2 is enabled  within the modern flavour.

## Installation method

- How is the GNUstep system installed?
> All is built from sources (latest commits).

## Applications

- How GNUstep applications are installed?
> All are built from sources thanks to agnostep-apps-manager.

## Helpers

- What helpers the project provides to glue all the stuf together?
> Installation bash scripts and Wizards:
>  - Agnowiz: core installation level;
>  - Agnostep-apps-manager then.

## Status

- What is the status of Agnostep
> It depends on the current release: latest commits may be unstable. Ever read CHANGES in each module repository.
> Published relesases are known to be stable.

## Wrappers

- Does Agnostep provide a Collection of applications or wrappers to respond for desktop tasks:
> Agnostep helps to install most of the available GNUstep applications from  the GAP collection, several from GSDE project, other dispatched in Github...
> It also provides some native applications: look at [agnostep-applications](../../../../agnostep-applications)...

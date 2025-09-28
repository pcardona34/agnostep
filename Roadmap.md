# The way to do it
Porting PiSiN Desktop to an agnostic installation process means to better clarify and dispatch the steps:
1) Setting the tools and the environment to build. Make them agnostic: maybe in something like a Docker container?
2) Installing the Window Manager;
3) Installing the Core GNUstep;
4) Installing the Frameworks;
5) Installing the apps, the extra apps, the devel apps and the games;
    a) Subtask: a better Web Browser wrapper to handle openURL service.
7) Installing the wrappers for non-GNUstep applications
   a) Subtask: removing/substituing specific tools like *rpinters* (setting the default printer) - *rpi-imager* (creating bootable image)
5) Installing the Desktop tools like *conky*, *dunst*, *Updater.sh* for all the users; the resources like the wallpaper;
  a) Subtask: changing the path of some tools to `/usr/local/bin` (no more `~/.local/bin`)
  b) AGNoStep-Art: a new wallpaper (without Pi ref) and new bannieres for the Help documents.
  c) Installing the walpaper in '/usr/share/wallpapers';
7) Installing the Themes of the Window Manager and of GNUstep for all the users;
8) Setting the user home directory and namely the chosen themes for each user.
    a) Subtask: updating some illustrations of the help files.
10) Making tests:
    a) For each step
    b) For the global 'enjoy.sh' installer script.
12) Installing the Display Manager.
    a) Updating the background.

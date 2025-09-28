# The way to do it
Porting PiSiN Desktop to an agnostic installation process means to better clarify and dispatch the steps:
1) Setting the tools and the environment to build. Make them agnostic: maybe in something like a Docker container?
2) Installing the Window Manager;
3) Installing the Core GNUstep;
4) Installing the Frameworks;
5) Installing the apps, the extra apps, the devel apps and the games;
5) Installing the Desktop tools like conky, dunst, updater for all the users;
6) Installing the Themes of the Window Manager and of GNUstep for all the users;
7) Setting the user home directory and namely the chosen themes for each user.
8) Making tests.
9) Installing the Display Manager.

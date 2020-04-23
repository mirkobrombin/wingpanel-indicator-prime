# PRIME indicator for Wingpanel
A PRIME mode switcher for wingpanel.

<div align="center">
  <img src="https://raw.githubusercontent.com/mirkobrombin/wingpanel-indicator-prime/master/data/screenshot.png">
</div>

## Build and Installation
You'll need the following dependencies:
* libgala-dev
* libgee-0.8-dev
* libglib2.0-dev
* libgranite-dev
* libgtk-3-dev
* meson
* libmutter-2-dev
* valac
* posix

Configure the build environment with meson:
```
meson build --prefix=/usr
cd build
ninja
```
Install:
```
sudo ninja install
```

## TODO
* Show Nvidia/Intel icons
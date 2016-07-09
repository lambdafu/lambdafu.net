---
title: Compiling FreeCad on Fedora 20
author: Marcus
date: 2014-02-22T00:11:38+00:00
url: /2014/02/22/compiling-freecad-on-fedora-20/
categories:
  - Programming
tags:
  - Fedora
  - FreeCad

---
[FreeCad][1] is a very promising free and portable CAD program. Unfortunately, it's dependency chain is a bit messy, and building those libraries is not for the faint of heart. Normally, GNU/Linux distributions do a good job on that for you, but in Fedora, the packaging is not quite up to date. The included FreeCad 0.13 works, kinda, but there are crashes and bugs like missing text rendering in Draft mode. As FreeCad is progressing fast, it is useful to build the latest version, and here is how to do just that on Fedora 20.

First, you install the dependencies, except for coin, soqt and python-pivy.

```
 $ sudo yum install cmake doxygen swig gcc-gfortran gettext dos2unix desktop-file-utils libXmu-devel freeimage-devel mesa-libGLU-devel OCE-devel python python-devel boost-devel tbb-devel eigen3-devel qt-devel qt-webkit-devel ode-devel xerces-c xerces-c-devel opencv-devel smesh-devel freetype freetype-devel libspnav-devel
```

Then you download and install the Coin3 source package by corsepiu:

```
 wget http://corsepiu.fedorapeople.org/packages/Coin3-3.1.3-4.fc19.src.rpm
 $ rpm -i Coin3-3.1.3-4.fc19.src.rpm
```

Which you can now build and install:

```
 $ rpmbuild -bb ~/rpm/SPECS/Coin3.spec
 $ sudo rpm -i ~/rpm/RPMS/x86_64/{Coin3-3.1.3-4.fc20.x86_64.rpm,Coin3-devel-3.1.3-4.fc20.x86_64.rpm}
```

Note that source packages are installed as normal user, while binary packages are installed as root. Verify that Coin3 is your active alternative for coin-config:

```
 $ alternatives --display coin-config
 coin-config - status is manual.
  link currently points to /usr/lib64/Coin3/coin-config
 ...
```

If it is not, set it with \`alternatives &#8211;set coin-config\`.

Now you have to rebuild and install a bunch of packages depending on Coin2 in Fedora 20. By rebuilding them, you make them depend on Coin3, which is what FreeCad expects.

```
 $ yumdownloader --source SoQt SIMVoleon python-pivy
 $ rpm -i SoQt-1.5.0-10.fc20.src.rpm SIMVoleon-2.0.1-16.fc20.src.rpm python-pivy-0.5.0-6.hg609.fc20.src.rpm
 $ rpmbuild -bb ~/rpm/SPECS/SoQt.spec
 $ sudo rpm -i ~/rpm/RPMS/x86_64/{SoQt-1.5.0-10.fc20.x86_64.rpm,SoQt-devel-1.5.0-10.fc20.x86_64.rpm}
 $ rpmbuild -bb ~/rpm/SPECS/SIMVoleon.spec
 $ sudo rpm -i ~/rpm/RPMS/x86_64/{SIMVoleon-2.0.1-16.fc20.x86_64.rpm,SIMVoleon-devel-2.0.1-16.fc20.x86_64.rpm}
 $ rpmbuild -bb ~/rpm/SPECS/python-pivy.spec
 $ sudo rpm -i ~/rpm/RPMS/x86_64/python-pivy-0.5.0-6.hg609.fc20.x86_64.rpm
```

Now you can finally download and build FreeCad:

```
 $ git clone git@github.com:lambdafu/FreeCAD_sf_master.git freecad
 $ mkdir build
 $ cd build
 $ cmake ../freecad
 $ make -j 8
```

This will take a while. When it has finished, you can start FreeCad with:

```
 $ bin/FreeCad
```

Have Fun!

 [1]: http://www.freecadweb.org/
tools/README.txt
================

Contents:

  o buildtest
  o genromfs-0.5.2.tar.gz
  o kconfig-frontends
    - General Build Instructions
    - Graphical Configuration Tools
    - --program-prefix=
    - kconfig-frontends-3.3.0-1-libintl.patch
    - kconfig-macos.patch
    - kconfig-mconf Path Issues
    - gperf
    - kconfig-frontends for Windows
    - Buildroot
  o nxfuse
  o bcm43438
  o mkimage.sh

buildtest
=========

  This is a collection of adhoc scripts and data files that I used to
  to perform build testing in conjunction with nuttx/tools/testbuild.sh.
  These are not of general use as they are tied to my personal
  development environment.  The concepts may be useful to others,
  however, who may want to adapt this logic for their own purposes.

genromfs-0.5.2.tar.gz
=====================

  This is a snapshot of the genromfs tarball taken from
  http://sourceforge.net/projects/romfs/.  This snapshot is provided to
  assure that a working version of genromfs is always available for NuttX.

  This tool is also include in the buildroot and can be built automatically
  from the buildroot.

kconfig-frontends
=================
.configure script is modified so it can be easily compiled for Arch Linux based systems. Please make sure that aclocal and automake are on the latest version (>1.15). 
Install pkgconf package.
generate build for mconf target only.
General Build Instructions
--------------------------

  This is a snapshot of the kconfig-frontends version 4.11.0.1 tarball taken
  from http://ymorin.is-a-geek.org/projects/kconfig-frontends.

  General build instructions:

    cd kconfig-frontends
    ./configure --enable-mconf
    make
    make install

  It is a good idea to add '--enable-mconf' on the 'configure' command line.
  The kconfig-frontends make will generate many programs, but the NuttX
  build system only needs the 'kconfig-conf' and 'kconfig-mconf' programs.
  If the requirements for 'kconfig-mconf' are not supported by your system,
  the kconfig-frontends configuration system will not build it.  Adding the
  option --enable-mconf assures you that 'kconfig-mconf' will be built or
  if it is not built, it will tell you why it was not built.

  To suppress the 'nconf' and the graphical front-ends which are not used by
  NuttX, you can add:

    ./configure --enable-mconf --disable-nconf --disable-gconf --disable-qconf
    make
    make install

  To suppress the graphical interfaces, use static libraries, and disable
  creation of other utilities:

    ./configure --disable-shared --enable-static --enable-mconf --disable-nconf --disable-gconf --disable-qconf --disable-nconf --disable-utils
    make
    make install

  The default installation location for the tools is /usr/local/bin.  You
  may require root privileges to 'make install'.

Graphical Configuration Tools
-----------------------------

  If you have an environment that suppots the Qt or GTK graphical systems
  (probably KDE or gnome, respectively), then you can also build the
  graphical kconfig-frontends, kconfig-qconf and kconfig-gconf:

    ./configure --enable-mconf --disable-nconf --disable-gconf --enable-qconf
    make
    make install

  Or,

    ./configure --enable-mconf --disable-nconf --enable-gconf --disable-qconf
    make
    make install

  In these case, you can start the graphical configurator in the nuttx/
  directory with either:

    make qconfig

  or

    make gconfig

--program-prefix=
-----------------

  Beginning somwhere between version 3.3.0 and 3.6.0, the prefix was added
  to the kconfig-frontends tools.  The default prefix is kconfig-.  So,
  after 3.3.0, conf becomes kconfig-conf, mconf becomes kconfig-mconf, etc.
  All of the NuttX documentation, Makefiles, scripts have been updated to
  used this default prefix.

  This introduces an incompatibility with the 3.3.0 version.  In the 3.6.0
  timeframe, the configure argument --program-prefix= was added to
  eliminated the kconfig- prefix.  This, however, caused problems when we
  got to the 3.7.0 version which generates a binary called kconfig-diff
  (installed at /usr/local/bin).  Without the prefix, may conflict with
  the standard diff utility (at /bin), depending upon how your PATH
  variable is configured.  Because of this, we decided to "bite the bullet"
  and use the standard prefix at 3.7.0 and later.

  This problem could probably also be avoided using --disable-utils.

kconfig-frontends-3.3.0-1-libintl.patch
---------------------------------------

  The above build instructions did not work for me under my Cygwin
  installation with kconfig-frontends-3.3.0.  This patch is a awful hack
  but will successfully build 'kconfig-mconf' under Cygwin.

    cat kconfig-frontends-3.3.0-1-libintl.patch | patch -p0
    cd kconfig-frontends-3.3.0-1
    ./configure --disable-gconf --disable-qconf
    make
    make install

  Update: Version 3.6.0 (and above) will build on Cygwin with no patches.

  The NuttX tools repository has kconfig-frontends-3.12 and
  kconfig-frontends-4.11, both of which build without this patch.

kconfig-macos.patch
-------------------

  This is a patch to make the kconfig-frontends-3.3.0 build on Mac OS X.

  To build the conf and mconf frontends, use the following commands:

    ./configure --disable-shared --enable-static --disable-gconf --disable-qconf --disable-nconf --disable-utils
    make
    make install

  The NuttX tools repository has kconfig-frontends-3.12 and
  kconfig-frontends-4.11, both of which build without this patch.

kconfig-mconf Path Issues
-------------------------

Some people have experienced this problem after successfully building and installing
the kconfig-frontends tools:

  kconfig-mconf: error while loading shared libraries: libkconfig-parser-3.8.0.so: cannot open shared object file: No such file or directory
  make: *** [menuconfig] Error 127

There two known solutions to this:

1) Add the directory where the kconfig-frontends libraries were installed
   to the file /etc//ld.so.conf (probably /usr/local/lib), then run the
   ldconfig tool.

2) Specify the LD_RUN_PATH environment when building the kconfig-frontends
   tools like:

     ./configure --enable-mconf
     LD_RUN_PATH=/usr/local/lib
     make
     make install

3) Build the kconfig-frontends tools using only static libraries:

     ./configure --enable-mconf --disable-shared --enable-static

I have also been told that some people see this error until they re-boot, then it
just goes away.  I would try that before anything else.

gperf
-----

  "I am getting an error when configuring the kconfig-frontends-3.12.0.0 package.
   Using command

    ./configure --enable-mconf

  "It says it 'configure: error: can not find gperf'"

   If you see this, make sure that the gperf package is installed.

gperf 3.1 and above
-------------------

Version 3.12.0 of kconfig-frontends did not not build with gperf
(version 3.1 released 2017-01-05).  A files suggested by Harald
Gutsche  (Bitbucket Issue #1) is:  I changed the type in line 12 to size_t:

static const struct kconf_id *kconf_id_lookup(register const char *str, register size_t len);

Philiipp Krause also notes that current 4.11.0.1 release also has
issues, but can be fixed with a change to just one line (also Bitbucket
Issue #1)):

Change line 175 of hconf.c from

  kconf_id_lookup (register const char *str, register unsigned int len)

to
  kconf_id_lookup (register const char *str, register GPERF_LEN_TYPE len)

With this change, upstream should build fine both with gperf 3.1 and older
versions.

NOTE:  This change has already been applied in the code base.  See also
gperf3.1_kconfig_id_lookup.patch

See kconfig-frontends-3.12.0-sizet.patch for the 3.12.0 version.
(from https://gist.github.com/KamilSzczygiel/d16a5d88075939578f7bd8fadd0907aa)

kconfig-frontends for Windows
-----------------------------

Recent versions of NuttX support building NuttX from a native Windows
console window (see "Native Windows Build" below).  But kconfig-frontends
is a Linux tool.  At one time this was a problem for Windows users, but
now there is a specially modified version of the kconfig-frontends tools
that can be used:
http://uvc.de/posts/linux-kernel-configuration-tool-mconf-under-windows.html

[The remainder of the text in this section is for historical interest only]

From https://groups.yahoo.com/neo/groups/nuttx/conversations/messages/2900:

"The build was quite simple:

I used mingw installer and I had to install two packages that the
automated mingw setup does not bring by default:

  * mingw-get update
  * mingw-get install mingw32-pdcurses mingw32-libpdcurses
  * mingw-get install msys-regex msys-libregex

(grep the output of mingw-get list if I got the names wrong)

Then I had to change some things in mconf code, it was quite simple to
understand the make errors.

  * The first of them is to disable any use of uname() in symbol.c and
    replace the uname output by a constant string value (I used MINGW32-MSYS),

  * The second one is related to the second parameter to mkdir() that has
    to disappear for windows (we don't care about folder rights) in confdata.c;

  * And the last one of them involves #undef bool in dialog.h before including
    curses.h (CURSES_LOC), around line 30.

I wrapped all of my changes in #if(n)def __MINGW32__, but that is not
sufficient to make that work everywhere, I think.

So mconf itself has some portability issues that shall be managed in a
cleaner way, what I did was just hacks, I don't think they are
acceptable by mconf upstream maintainers.

Here is the magic incantation to get the whole thing working. It seems
that the configure script is not so good and does not bring the required
bits to link libregex.

  CFLAGS="-I/mingw/include -I/usr/include" LDFLAGS="-Bstatic -L/mingw/lib
         -L/usr/lib -lregex" ./configure --enable-frontends=mconf --enable-static
         --disable-shared

So the message I want to pass is that native "make menuconfig" in
windows IS POSSIBLE, I have done it in a few minutes."

"Oops, forgot something, I had to bring a gperf binary from the gnuwin32 project."

- Sebastien Lorquet

Buildroot
---------
As of 2014-3-7, the kconfig-frontends tools have been included in the
buildroot tool set.  This means that in one package you can build GCC tools
that are especially tuned for NuttX and all of the support tools that you
need ROMFS, configuration, and NXFLAT.

nxfuse
======

A Linux FUSE implementation that enables native mounting of NuttX filesystems
in Linux.  Currently supports SmartFS and NXFFS (within the limitations of
the NXFFS architecture).  See the nxfuse/README.txt file for further information.

bcm43438
========

A snapshot of free-use but proprietary firmware for use with the BCM43438

mkimage.sh
==========

The creates a download-able image as needed for use with the RRLOAD
bootloader.  The RRLOAD binary format used with BSPs from www.ridgerun.com
using the mkimage.sh script.  This only applies to the again port to the
TI/Spectrum Digital C5471 board which may include the RRLOAD bootloader.

It resides here (vs. nuttx/tools/.) because it has a GPL license.

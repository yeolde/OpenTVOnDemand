OpenTVOnDemand
==============

Open source tool in Bash for online TV stream capturing.

[Project Site](https://github.com/x43x61x69/OpenTVOnDemand)

![screenshot](https://dl.dropboxusercontent.com/s/liwktatbylm6015/OpenTVOnDemand.png)


Description
-----------

The source code served as an example of how online TV system works, 
it is, by no means, a commercial grade product. It might contain 
errors or flaws, and it was created for demonstration purpose only.

OpenTVOnDemand supports most of the current major North America TV 
providers's full episode stream capturing. This script will likely 
not be updated in the future.

The following channels were supported by OpenTVOnDemand:

* A&E
* ABC
* BBC
* Bio
* Bravo
* CBS
* FOX
* FX
* GlobalTV
* Lifetime
* NBC
* SBS
* SyFy
* TheCW
* USA

*IT SHOULD ONLY BE USE IF YOU HAVE THE OWNERSHIP OF THE DOWNLOADING CONTENTS. 
IT DOES NOT SUPPORT THOSE VIDEOS WHICH NEEDS LOGIN TO VIEW.*

It currently support both Mac OS X (Darwin) and Linux. Howerver, some necessary depandencies must be installed for it to work.

For Mac OS X:
* [Homebrew](https://github.com/Homebrew/) (`ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"`)
* GNU Core Utilities (via Homebrew, `brew install coreutils`) 
* RTMPDump (via Homebrew, `brew install rtmpdump`) 
* FFmpeg (via Homebrew, `brew install ffmpeg`) 
* GNU parallel (via Homebrew, `brew install parallel`) 
* jsawk (via Homebrew, `brew reinstall readline --force` then `brew install jsawk`) 
* Terminal-Notifier (Optional, Xcode is needed for compiling. via Homebrew, `brew install terminal-notifier`)

For Linux:
* RTMPDump (`sudo apt-get install rtmpdump`) 
* FFmpeg (`sudo apt-get install ffmpeg`) 
* GNU parallel (`sudo apt-get install parallel`) 
* jsawk (`wget http://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz && tar -zxvf js-1.7.0.tar.gz && cd js/src && make BUILD_OPT=1 -f Makefile.ref && make BUILD_OPT=1 JS_DIST=/usr/local -f Makefile.ref export && cd .. && cd .. && rm -rf js && curl -L http://github.com/micha/jsawk/raw/master/jsawk > jsawk && chmod 755 jsawk && mv jsawk /usr/local/bin/`)


Changelog
---------

v0.1:
* Initial release.


License
-------

Copyright (C) 2014  Cai, Zhi-Wei.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

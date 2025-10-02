#!/bin/sh

# When working on BSD: Run with 'bash testrun.sh', this
# will not work with sh (didn't get ANSI colors to work w/ it) :->

# To get UKRunner working with correct i18n, copy the English.lproj
# manually like this:
# mkdir -p /opt/GNUstep/Local/Tools/Resources/ukrun
# cp -v English.lproj /opt/GNUstep/Local/Tools/Resources/ukrun
# English.lproj can be found somewhere in the UnitKit directory.

ukrun RSSKitTests.bundle/ 2> /dev/null | sed -e $'s/Failed/\x1b[31mFAILED\x1b[39m/' -e $'s/Passed/\x1b[32mPASSED\x1b[39m/'


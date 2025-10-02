/*
**  GNUMail_main.m
**
**  Copyright (c) 2003-2006 Ludovic Marcotte
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/AppKit.h>

#include "GNUMail.h"
#include "Constants.h"

//
// Starting point of GNUMail
//
int main(int argc, const char *argv[], char *env[])
{
  NSAutoreleasePool *pool;
  GNUMail *gnumail;

  pool = [[NSAutoreleasePool alloc] init];
  gnumail = [[GNUMail alloc] init];

  [NSApplication sharedApplication];
  [NSApp setDelegate: gnumail];

  NSApplicationMain(argc, argv);

  RELEASE(gnumail);
  RELEASE(pool);

  return 0;
}

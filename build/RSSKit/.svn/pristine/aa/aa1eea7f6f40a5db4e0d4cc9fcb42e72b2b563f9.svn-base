/*  -*-objc-*-
 *
 *  GNUstep RSS Kit
 *  Copyright (C) 2006 Guenther Noack
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation, in version 2.1
 *  of the License
 * 
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA
 */

// Dublin Core Module
// Written by Guenther Noack <guenther@unix-ag.uni-kl.de>


// For the date format, please consider taking a look at
// http://www.w3.org/TR/NOTE-datetime

#import "DublinCore.h"
//#define DEBUG 1

// -------------------------------------------------------------
//                G L O B A L   V A R I A B L E S


// index always points to the *next* character
// this is a global variable so that you can find out where it failed.
int position;

NSString* dc_error;


// -------------------------------------------------------------
//                          M A C R O S


#define nextIsNumber (isdigit(str[position]))

#define breakMethod(reason) \
{                           \
  free(str);                \
  dc_error = reason;        \
  return nil;               \
}


#define eatNextNumber(item)                           \
{                                                     \
  (item) = (item)*10 + (str[position]-(unichar)'0');  \
  position++;                                         \
}



#define indexOutOfBounds (position>=length)


#define eatNextNumberOrBreak(item) \
{                                  \
  if (indexOutOfBounds)            \
    breakMethod(@"index out of bounds"); \
                                   \
  if (nextIsNumber)                \
    eatNextNumber((item))          \
  else                             \
    breakMethod(@"not a number");  \
}

#define eatNextNumberOrBreakTimes(item,n) \
{                                         \
  for(i=0;i<(n);i++)                      \
    {                                     \
      eatNextNumberOrBreak((item));       \
    }                                     \
}

#define eat(character,retval) \
{                             \
  if (indexOutOfBounds)       \
      return retval;          \
			      \
  if (str[position]!=character)  \
    breakMethod(@"expected something else"); \
                              \
  position++;                 \
}

#define successReturnValue            \
[ NSCalendarDate                      \
  dateWithYear: ((year!=0)?year:2005) \
  month: ((month!=0)?month:1)         \
  day: ((dayOfMonth!=0)?dayOfMonth:1) \
  hour: hours                         \
  minute: minutes                     \
  second: seconds                     \
  timeZone: timeZone                  ]

#define eatOrSucceed(character) \
 eat(character,successReturnValue);

#define eatOrDie(character) \
 eat(character,nil);



// -------------------------------------------------------------
//                     D A T E   P A R S E R


NSDate* parseDublinCoreDate( NSString* dateStr )
{
  unichar* str;
  int length;
  int i; // just for small loops
  
  int year        =0;
  int month       =0;
  int dayOfMonth  =0;
  int hours       =0;
  int minutes     =0;
  int seconds     =0;
  int deciseconds =0;
  
  NSTimeZone* timeZone = nil;
  int tzHrs  =0;
  int tzMins =0;
  int tzSign =0;
    
  length = [dateStr length];
  
  str = (unichar*) malloc(length*sizeof(unichar));
  [dateStr getCharacters: str];
  
  // reset position
  position = 0;
  
  eatNextNumberOrBreakTimes(year,4);
  
  eatOrSucceed('-');
  
  eatNextNumberOrBreakTimes(month,2);
  
  eatOrSucceed('-');
  
  eatNextNumberOrBreakTimes(dayOfMonth,2);
  
  eatOrSucceed('T');
  
  eatNextNumberOrBreakTimes(hours,2);
  
  eatOrDie(':');
  
  eatNextNumberOrBreakTimes(minutes,2);
  
  // Optional Seconds
  
  if (indexOutOfBounds)
    breakMethod(@"out of bounds where seconds or TZD should follow");
  
  if (str[position] == (unichar)':')
    {
      position++;
      
      eatNextNumberOrBreakTimes(seconds,2);
      
      if (indexOutOfBounds)
	breakMethod(@"out of bounds where deciseconds or TZD should follow");
      
      if (str[position] == (unichar)'.')
	{
	  position++;
	  eatNextNumberOrBreak(deciseconds);
	}
    }
  
  // Time Zone
  if (indexOutOfBounds)
    breakMethod(@"out of bounds where time zone definition should follow");
  
  if (str[position] == (unichar)'-')
    {
      eatOrDie('-');
      tzSign = -1;
      // GOTO PARSETZDREST
    }
  else if (str[position] == (unichar)'+')
    {
      eatOrDie('+');
      tzSign = 1;
      // GOTO PARSETZDREST
    }
  
  // putting together the time zone
  if (tzSign != 0)
    {
      // PARSETZDREST:
      
      eatNextNumberOrBreakTimes(tzHrs,2);
      eatOrDie(':');
      eatNextNumberOrBreakTimes(tzMins,2);
      
      timeZone =
	[NSTimeZone
	  timeZoneForSecondsFromGMT: tzSign * ((tzHrs*60 + tzMins)*60)];
    }
  else
    {
      NSString* subStr = [dateStr substringFromIndex: position];
      
      timeZone = [NSTimeZone timeZoneWithAbbreviation: subStr];
    }

  /* Process is done. It should be safe to free str */
  free(str);
  
  return successReturnValue;
}



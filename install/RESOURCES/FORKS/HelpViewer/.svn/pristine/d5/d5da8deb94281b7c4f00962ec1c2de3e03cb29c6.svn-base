/*
    This file is part of HelpViewer (http://gap.nongnu.org/helpviewer/)
    Copyright (C) 2003 Nicolas Roard <nicolas@roard.com>    
                  2025 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.  
    31 Milk Street #960789 Boston, MA 02196 USA
*/

#import "Parser.h"
#import "ModNSString.h"

/*
   I rewrote this very simple SAX-inspired Parser ...
   Very basic, but for HelpViewer needs it's enough 
*/

#define RESET(str) [str release]; str = [[NSMutableString alloc] init];

#define MAX_ENTITY_LEN 16

@implementation Parser

+ (instancetype) parserWithSAXHandler: (id<SAXHandler>) handler withData: (NSData*) data
{
  return [[[self alloc] initWithSAXHandler: handler withData: data] autorelease];
}

- (instancetype) initWithSAXHandler: (id<SAXHandler>) handler withData: (NSData*) data
{
  if ((self = [super init]))
    {
      _data = data;
      [_data retain];
      _handler = handler;
    }
  return self;
}

- (void) dealloc
{
  [_data release];
  [super dealloc];
}

- (BOOL) parse
{
  NSString* file = [[NSString alloc] initWithData: _data encoding: NSUTF8StringEncoding];

  if (file != nil)
    {
      NSMutableString* current = [[NSMutableString alloc] init];
      NSUInteger i;
      unsigned entityIdx = 0;
      char entityBuf[MAX_ENTITY_LEN+1];
      BOOL inEntity = NO;;
      BOOL Tag = NO;
      BOOL isEndingTag = NO;
      BOOL attributeStarted = NO;
      NSString* tagName = nil;
      NSString* keyAttribute = nil;
      NSMutableDictionary* tagAttributes = nil;

      NSLog (@"file length : %lu", (unsigned long)[file length]);
        
      for (i=0; i < [file length]; i++)
	{
          unichar c = [file characterAtIndex: i];

          if (!inEntity && c == '&')
            {
              entityIdx = 0;
              inEntity = YES;
            }
          else if (inEntity)
            {
              if (c == ';')
                {
                  NSString *entityStr = nil;

                  entityBuf[entityIdx] = '\0';
                  entityStr = charFromEntity(entityBuf);
                  if (entityStr)
                    [current appendString : entityStr];
                  inEntity = NO;
                }
              else
                {
                  entityBuf[entityIdx] = (char)c;
                  entityIdx++;
                  if (entityIdx == MAX_ENTITY_LEN)
                    {
                      entityBuf[entityIdx-1] = '\0';
                      NSLog(@"found too long entity name to store in buffer. Got up to |%s|", entityBuf);
                      inEntity = NO;
                    }
                }
            }
          else if ((!Tag) && (c == '<'))
	    {
              // We have a tag ...
              Tag = YES;

              // We send the previous characters to the handler
              [_handler characters: current];

              // We recreate a current string
              RESET (current);
	    }
          else if ((Tag) && (c == '>')) 
	    {
              // We close a tag ...
              Tag = NO;

              // We send the tag to the handler
              if (isEndingTag)
		{
		  NSLog(@"Ending tag, current is %@ but tag name is %@ attributes %@", current, tagName, tagAttributes);
		  // <tag/> shortcut detected, start-end together
		  if ([current length] == 0)
		    {
                      NSLog(@"XML short ending. Current is %@ but tag name is %@", current, tagName);
                      [_handler startElement: tagName attributes: tagAttributes];
                      [_handler endElement: tagName];
                      [tagName release]; tagName = nil;
                      [keyAttribute release]; keyAttribute = nil;
                      [tagAttributes release]; tagAttributes = nil;
		    }
		  else
		    {
		      [_handler endElement: current];
		    }
                  isEndingTag = NO;
		}
              else
		{
                  if (tagName == nil)
		    {
                      // If no tag name, current == tag name ...
                      NSLog(@"begin tag %@ with no attributes", current);
                      [_handler startElement: current attributes: nil];
		    }
                  else
		    {
                      NSLog(@"begin tag %@ with %@ attributes", tagName, tagAttributes);
                      [_handler startElement: tagName attributes: tagAttributes];
		    }
                  [tagName release]; tagName = nil;
                  [keyAttribute release]; keyAttribute = nil;
                  [tagAttributes release]; tagAttributes = nil;
		}
              RESET (current);
	    }
          else 
	    {
              // other character ...
              if (Tag)
		{
                  if (c == '/')
		    {
                      // We have a closing tag
                      // FIXME : this approach is not optimal and could be wrong
                      isEndingTag = YES;
		    }
                  else if (c == ' ')
		    {
                      if (tagName == nil)
			{
                          // We set the tag name
                          tagName = [[NSString alloc] initWithString: current];
                          RESET (current);
			}
                      else
                        {
                          // careful, don't chew spaces inside tag attributes
                          [current appendString : [NSString stringWithCharacters: &c length: 1]];
                        }
		    }
                  else if (c == '=')
		    {
                      if (keyAttribute != nil)
                        {
                          [keyAttribute release];
                        }
 
                      keyAttribute = RETAIN ([current stringByTrimmingSpaces]);
                      RESET (current);
                      if (tagAttributes == nil) 
			{
                          tagAttributes = [[NSMutableDictionary alloc] init];
			}
                      attributeStarted = NO;
		    }
                  else if (c == '"') 
		    {
                      if (attributeStarted)
			{
                          if (keyAttribute != nil)
                            {
                              [tagAttributes setObject: current forKey: keyAttribute];
                              [keyAttribute release]; keyAttribute = nil;
                              RESET (current);
                            }
                          else
                            {
                              NSLog(@"Unexpected token \"");
                            }
			}
                      else 
			{
                          attributeStarted = YES;
                          RESET (current);
			}
		    }
                  else
		    [current appendString : [NSString stringWithCharacters: &c length: 1]];
		}
              else
		[current appendString : [NSString stringWithCharacters: &c length: 1]];
	    }
	}

      // we ended without a tag, but have characters left
      if (current && [current length])
        {
          [_handler characters: current];
        }
      NSLog (@"Parse end !");

      [file release];
      [current release];
      [tagName release]; 
      [keyAttribute release]; 
      [tagAttributes release]; 
    }
  return YES;
}


@end


NSString *charFromEntity(char *entityName)
{
  NSString *entity = nil;
  unsigned i;
  unichar c = '\0';
  
  struct
  {
    char *name;
    unichar chr;
  } refs[] = {
    { "lt"    , '<'       },
    { "gt"    , '>'       },
    { "amp"   , '&'       },
    { "quot"  , '"'       },
    { "apos"  , '\''      },
    { "nbsp"  , (unichar)160 },
    { "iexcl" , (unichar)161 },
    { "cent"  , (unichar)162 },
    { "pound" , (unichar)163 },
    { "curren", (unichar)164 },
    { "yen"   , (unichar)165 },
    { "brvbar", (unichar)166 },
    { "sect"  , (unichar)167 },
    { "uml"   , (unichar)168 },
    { "copy"  , (unichar)169 },
    { "ordf"  , (unichar)170 },
    { "laquo" , (unichar)171 },
    { "not"   , (unichar)172 },
    { "shy"   , (unichar)173 },
    { "reg"   , (unichar)174 },
    { "macr"  , (unichar)175 },
    { "deg"   , (unichar)176 },
    { "plusmn", (unichar)177 },
    { "sup2"  , (unichar)178 },
    { "sup3"  , (unichar)179 },
    { "acute" , (unichar)180 },
    { "micro" , (unichar)181 },
    { "para"  , (unichar)182 },
    { "middot", (unichar)183 },
    { "cedil" , (unichar)184 },
    { "sup1"  , (unichar)185 },
    { "ordm"  , (unichar)186 },
    { "raquo" , (unichar)187 },
    { "frac14", (unichar)188 },
    { "frac12", (unichar)189 },
    { "frac34", (unichar)190 },
    { "iquest", (unichar)191 },
    { "Agrave", (unichar)192 },
    { "Aacute", (unichar)193 },
    { "Acirc" , (unichar)194 },
    { "Atilde", (unichar)195 },
    { "Auml"  , (unichar)196 },
    { "Aring" , (unichar)197 },
    { "AElig" , (unichar)198 },
    { "Ccedil", (unichar)199 },
    { "Egrave", (unichar)200 },
    { "Eacute", (unichar)201 },
    { "Ecirc" , (unichar)202 },
    { "Euml"  , (unichar)203 },
    { "Igrave", (unichar)204 },
    { "Iacute", (unichar)205 },
    { "Icirc" , (unichar)206 },
    { "Iuml"  , (unichar)207 },
    { "ETH"   , (unichar)208 },
    { "Ntilde", (unichar)209 },
    { "Ograve", (unichar)210 },
    { "Oacute", (unichar)211 },
    { "Ocirc" , (unichar)212 },
    { "Otilde", (unichar)213 },
    { "Ouml"  , (unichar)214 },
    { "times" , (unichar)215 },
    { "Oslash", (unichar)216 },
    { "Ugrave", (unichar)217 },
    { "Uacute", (unichar)218 },
    { "Ucirc" , (unichar)219 },
    { "Uuml"  , (unichar)220 },
    { "Yacute", (unichar)221 },
    { "THORN" , (unichar)222 },
    { "szlig" , (unichar)223 },
    { "agrave", (unichar)224 },
    { "aacute", (unichar)225 },
    { "acirc" , (unichar)226 },
    { "atilde", (unichar)227 },
    { "auml"  , (unichar)228 },
    { "aring" , (unichar)229 },
    { "aelig" , (unichar)230 },
    { "ccedil", (unichar)231 },
    { "egrave", (unichar)232 },
    { "eacute", (unichar)233 },
    { "ecirc" , (unichar)234 },
    { "euml"  , (unichar)235 },
    { "igrave", (unichar)236 },
    { "iacute", (unichar)237 },
    { "icirc" , (unichar)238 },
    { "iuml"  , (unichar)239 },
    { "eth"   , (unichar)240 },
    { "ntilde", (unichar)241 },
    { "ograve", (unichar)242 },
    { "oacute", (unichar)243 },
    { "ocirc" , (unichar)244 },
    { "otilde", (unichar)245 },
    { "ouml"  , (unichar)246 },
    { "divide", (unichar)247 },
    { "oslash", (unichar)248 },
    { "ugrave", (unichar)249 },
    { "uacute", (unichar)250 },
    { "ucirc" , (unichar)251 },
    { "uuml"  , (unichar)252 },
    { "yacute", (unichar)253 },
    { "thorn" , (unichar)254 },
    { "yuml"  , (unichar)255 },
    { "bull"  , (unichar)8226 }
  };

  if (entityName[0] == '\0')
    {
      NSLog(@"mapping nil string");
      return nil;
    }
  else if (entityName[0] == '#')
    {
      NSLog(@"dec/hex entity: %s", entityName);
      if (strlen(entityName) < 8)
        {
          uint32_t val;

          // &#ddd; or &#xhh;
          if (sscanf(entityName+1, "x%x;", &val) || sscanf(entityName+1, "%d;", &val))
            {
              // &#xhh; hex value or &ddd; decimal value
              if (val > 0xffff)
                {
                  unichar       buf[2];

                  /* Convert codepoint outside base plane to surrogate pair
                   */
                  val -= 0x010000;
                  buf[0] = (val / 0x400) + 0xd800;
                  buf[1] = (val % 0x400) + 0xdc00;
                  entity = [[NSString alloc] initWithCharacters: buf length: 2];
                }
              else
                {
                  unichar       uc = (unichar)val;

                  entity = [[NSString alloc] initWithCharacters: &uc length: 1];
                }
            }
        }
    }
  else
    {
      for (i = 0; i < sizeof(refs)/sizeof(refs[0]); i++)
        {
          if (strcmp(refs[i].name, entityName) == 0)
            {
              c = refs[i].chr;
              break;
            }
        }
      if (c != 0)
        entity = [[NSString alloc] initWithCharacters: &c length: 1];
      else
        NSLog(@"entity %s not mapped", entityName); 
    }

  return AUTORELEASE(entity);
}

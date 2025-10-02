/*
**  NSAttributedString+Extensions.m
**
**  Copyright (c) 2004-2007 Ludovic Marcotte
**  Copyright (C) 2015-2017 Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
*+          Riccardo Mottola
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

#import "NSAttributedString+Extensions.h"

#import "Constants.h"
#import "ExtendedTextAttachmentCell.h"
#import "FilterManager.h"
#import "GNUMail.h"
#import "MailHeaderCell.h"
#import "MailWindowController.h"
#import "MimeType.h"
#import "MimeTypeManager.h"
#import "NSAttributedString+TextEnriched.h"
#import "NSColor+Extensions.h"
#import "NSFont+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "Task.h"
#import "TaskManager.h"
#import "ThreadArcsCell.h"
#import "Utilities.h"

#import <Pantomime/CWFolder.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWMIMEMultipart.h>
#import <Pantomime/CWMIMEUtility.h>
#import <Pantomime/CWPart.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

#define APPEND_HEADER(name, value) ({ \
  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: [NSString stringWithFormat: @"%@: ", _(name)] \
						     attributes: headerNameAttribute] ]; \
  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: value \
						     attributes: headerValueAttribute] ]; \
  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" \
						     attributes: nil] ]; \
})

//
//
//
static inline NSUInteger levelFromString(NSString *theString, NSUInteger start, NSUInteger end)
{
  NSUInteger i, level;
  unichar c;
  
  for (i = start,level = 0; i < end; i++)
    {
      c = [theString characterAtIndex: i];

      if (c == '>')
	{
	  level++;
	}
      else if (c > 32)
	{
	  break;
	}
    }

  return level;
}

//
//
//
@implementation NSAttributedString (GNUMailAttributedStringExtensions)

+ (NSAttributedString *) attributedStringFromAttachmentPart: (CWPart *) thePart
{
  NSMutableAttributedString *maStr;
  NSTextAttachment *aTextAttachment;
  ExtendedTextAttachmentCell *cell;
  NSFileWrapper *aFileWrapper;
  MimeType *aMimeType;
  NSImage *anImage;
  NSData *aData;
  NSUInteger len;

  maStr = [[NSMutableAttributedString alloc] init];
  aData = ([[thePart content] isKindOfClass: [CWMessage class]] ? (id)[(CWMessage *)[thePart content] rawSource] : (id)[thePart content]);
  aFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents: aData];

  if (![thePart filename])
    {
      if ([[thePart content] isKindOfClass: [CWMessage class]])
	{
	  [aFileWrapper setPreferredFilename: @"message/rfc822"];
	  len = [thePart size];
	}
      else 
	{
	  [aFileWrapper setPreferredFilename: @"unknown"];
	  len = [aData length];
	}
    }
  else
    {
      [aFileWrapper setPreferredFilename: [thePart filename]];
      len = [aData length];
    }

  aMimeType = [[MimeTypeManager singleInstance] 
		mimeTypeForFileExtension: [[aFileWrapper preferredFilename] pathExtension]];
  anImage = [[MimeTypeManager singleInstance] bestIconForMimeType: aMimeType
					      pathExtension: [[aFileWrapper preferredFilename] 
							       pathExtension]];

  // If the image has been loaded sucessfully, it become our icon for our filewrapper
  if (anImage)
    {
      [aFileWrapper setIcon: anImage];
    } 	
  
  aTextAttachment = [[NSTextAttachment alloc] initWithFileWrapper: aFileWrapper];
  
  // We add this attachment to our 'Save Attachment' menu
  [(GNUMail *)[NSApp delegate] addItemToMenuFromTextAttachment: aTextAttachment];
  
  cell = [[ExtendedTextAttachmentCell alloc] initWithFilename: [aFileWrapper preferredFilename]
					     size: len];
  [cell setPart: thePart];
  [aTextAttachment setAttachmentCell: cell];
  
  // Cocoa bug
  // FIXME RM: 2015-05-22, setting the image cell is needed on GNUstep too
#if defined(__APPLE__)
  [cell setAttachment: aTextAttachment]; // needed on Mac or filename will be missing whn trying to save
#endif
  [cell setImage: [aFileWrapper icon]];
  
  RELEASE(cell);
  RELEASE(aFileWrapper);
  
  // We separate the text attachment from any other line previously shown
  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" 
						     attributes: nil]];
  
  [maStr appendAttributedString: [NSAttributedString attributedStringWithAttachment:
						       aTextAttachment]];
  
  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" 
						       attributes: nil]];
  
  RELEASE(aTextAttachment);

  return AUTORELEASE(maStr);
}

//
// This method returns a NSAttributedString object that has been built
// from the content of the message.
//
+ (NSAttributedString *) attributedStringFromContentForPart: (CWPart *) thePart
						 controller: (id) theController
{
  NSMutableAttributedString *maStr;
  NSMutableDictionary *tAttr;
  
  tAttr = [[NSMutableDictionary alloc] init];
  
  [tAttr setObject: [NSFont messageFont]  forKey: NSFontAttributeName];
  
  maStr = [[NSMutableAttributedString alloc] init];
  
  if ([[thePart content] isKindOfClass: [CWMIMEMultipart class]])
    {
      // We first verify if our multipart object is a multipart alternative.
      // If yes, we represent the best representation of the part.
      if ([thePart isMIMEType: @"multipart"  subType: @"alternative"])
	{
	  // We append our \n to separate our body part from the headers
	  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" 
							     attributes: nil]];
	  
	  // We then append the best representation from this multipart/alternative object
	  [maStr appendAttributedString: [NSAttributedString attributedStringFromMultipartAlternative:
							       (CWMIMEMultipart *)[thePart content]
							     controller: theController]];
	}
      // Then we verify if our multipart object is a multipart appledouble.
      else if ([thePart isMIMEType: @"multipart"  subType: @"appledouble"])
	{
	  // We append our \n to separate our body part from the headers
	  [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" 
							     attributes: nil]];
	  
	  // We then append the best representation from this multipart/appledouble object
	  [maStr appendAttributedString: [NSAttributedString attributedStringFromMultipartAppleDouble:
							       (CWMIMEMultipart *)[thePart content]
							     controller: theController]];
	}
      // We have a multipart/mixed or multipart/related (or an other, unknown multipart/* object)
      else
	{
	  CWMIMEMultipart *aMimeMultipart;
	  CWPart *aPart;
	  NSUInteger i;
     
	  aMimeMultipart = (CWMIMEMultipart *)[thePart content];
     
	  for (i = 0; i < [aMimeMultipart count]; i++)
	    {
	      // We get our part
	      aPart = [aMimeMultipart partAtIndex: i];
	      
	      // We recursively call our method to show all parts
	      [maStr appendAttributedString: [self attributedStringFromContentForPart: aPart  controller: theController]];
	    }
	}
    }
  // We have a message with Content-Type: application/* OR audio/* OR image/* OR video/*
  // We can also have a text/* part that was base64 encoded, but, we skip it. It'll be
  // treated as a NSString object. (See below).
  else if ([[thePart content] isKindOfClass: [NSData class]])
    {
      NSTextAttachment *aTextAttachment;
      ExtendedTextAttachmentCell *cell;
      NSFileWrapper *aFileWrapper;
      
      MimeType *aMimeType;
      NSImage *anImage;
      
      NSRect rectOfTextView;
      NSSize imageSize;

      if ([thePart contentDisposition] == PantomimeAttachmentDisposition)
	{
	  [maStr appendAttributedString: [NSAttributedString attributedStringFromAttachmentPart: thePart]];
	}
      else
	{
	  //
	  // We try to display text/* and image/* parts. If we get anything else,
	  // we just display it as an attachment.
	  //
	  // RFC2046 - Section 5.2 says:
	  //
	  // 
	  // Default RFC 822 messages without a MIME Content-Type header are taken
	  // by this protocol to be plain text in the US-ASCII character set,
	  // which can be explicitly specified as:
	  // 
	  // Content-type: text/plain; charset=us-ascii
	  //
	  if ([thePart isMIMEType: @"text" subType: @"*"] || ![thePart contentType])
	    {
	      [maStr appendAttributedString: [NSAttributedString attributedStringFromTextPart: thePart]];
	    }
	  else if ([thePart isMIMEType: @"image"  subType: @"*"])
	    {
	      aFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents: (NSData *)[thePart content]];
	      
	      if (![thePart filename])
		{
		  [aFileWrapper setPreferredFilename: @"unknown"];
		}
	      else
		{
		  [aFileWrapper setPreferredFilename: [thePart filename]];
		}
	      
	      // We get the righ Mime-Type object for this part
	      aMimeType = [[MimeTypeManager singleInstance] 
			    mimeTypeForFileExtension: [[aFileWrapper preferredFilename] pathExtension]];
	      
	      if (aMimeType && [aMimeType view] == DISPLAY_AS_ICON)
		{
		  anImage = [[MimeTypeManager singleInstance] bestIconForMimeType: aMimeType
							      pathExtension: [[aFileWrapper preferredFilename] pathExtension]];
		}
	      else
		{
		  anImage = [[NSImage alloc] initWithData: (NSData *)[thePart content]];
		  AUTORELEASE(anImage);
		}
	      
	      // If the image has been loaded sucessfully, it become ours icon for our filewrapper
	      if (anImage)
		{
		  [aFileWrapper setIcon: anImage];
		} 	
	      
	      // We now rescale the attachment if it doesn't fit in the text view. That could happen
	      // very often for images.
	      rectOfTextView = [[[[GNUMail lastMailWindowOnTop] windowController] textView] frame];
	      imageSize = [[aFileWrapper icon] size];
	      
	      if (imageSize.width > rectOfTextView.size.width)
		{
		  double delta =  1.0 / (imageSize.width / (rectOfTextView.size.width-10));
		  [[aFileWrapper icon] setScalesWhenResized: YES];
		  [[aFileWrapper icon] setSize: NSMakeSize((imageSize.width*delta), imageSize.height*delta)];
		}
	      
	      // We now create our text attachment with our file wrapper
	      aTextAttachment = [[NSTextAttachment alloc] initWithFileWrapper: aFileWrapper];
	      
	      // We add this attachment to our 'Save Attachment' menu
	      [(GNUMail *)[NSApp delegate] addItemToMenuFromTextAttachment: aTextAttachment];
	      
	      cell = [[ExtendedTextAttachmentCell alloc] initWithFilename: [aFileWrapper preferredFilename]
							 size: [(NSData *)[thePart content] length] ];
	      [cell setPart: thePart];
	      
	      [aTextAttachment setAttachmentCell: cell];
	      
	      // Cocoa bug
#ifdef MACOSX
	      [cell setAttachment: aTextAttachment];
#endif
	      [cell setImage: [aFileWrapper icon]];

	      RELEASE(cell);
	      RELEASE(aFileWrapper);
	      
	      // We separate the text attachment from any other line previously shown
	      [maStr appendAttributedString: [NSAttributedString attributedStringWithString: @"\n" 
							     attributes: nil] ];
	      
	      [maStr appendAttributedString: [NSAttributedString attributedStringWithAttachment: aTextAttachment]];
	      RELEASE(aTextAttachment);
	    }
	  else
	    {
	      [maStr appendAttributedString: [NSAttributedString attributedStringFromAttachmentPart: thePart]];
	    }
	}
    }
  //
  // We have a message/rfc822 as the Content-Type.
  //
  else if ([[thePart content] isKindOfClass: [CWMessage class]])
    {
      CWMessage *aMessage;
      
      aMessage = (CWMessage *)[thePart content];
      
      // We must represent this message/rfc822 part as an attachment
      if ([thePart contentDisposition] == PantomimeAttachmentDisposition)
	{
	  [maStr appendAttributedString: [NSAttributedString attributedStringFromAttachmentPart: thePart]];
	}
      else
	{	      
	  [maStr appendAttributedString: [self attributedStringFromHeadersForMessage: aMessage
					       showAllHeaders: NO
					       useMailHeaderCell: NO] ];
	  [maStr appendAttributedString: [self attributedStringFromContentForPart: aMessage  controller: theController]];
	}
    }
  //
  // We have something that we probably can't display.
  // Let's inform the user about this situation.
  // 
  else if ([thePart isKindOfClass: [CWMessage class]] && ![thePart content])
    {
      CWMessage *aMessage;
      Task *aTask;

      [maStr appendAttributedString: [NSAttributedString attributedStringWithString: _(@"Loading message...")
							 attributes: nil]];
      
      aMessage = (CWMessage *)thePart;
      [aMessage setProperty: [NSNumber numberWithBool: YES]  forKey: MessagePreloading];
      
      aTask = [[TaskManager singleInstance] taskForService: [[aMessage folder] store]  message: aMessage];

      if (!aTask)
	{
	  aTask = [[Task alloc] init];
	  [aTask setKey: [Utilities accountNameForFolder: [aMessage folder]]];
	  aTask->op = LOAD_ASYNC;
	  aTask->immediate = YES;
	  aTask->total_size = (float)[aMessage size]/(float)1024;
	  [aTask setMessage: aMessage];
	  aTask->service = [[aMessage folder] store];
	  [[TaskManager singleInstance] addTask: aTask];
	  RELEASE(aTask);
	}
      
      [aTask addController: theController];
    }
  
  RELEASE(tAttr);

  return AUTORELEASE(maStr);
}


//
// This method returns a NSAttributedString object that has been built
// from the headers of the message.
//
+ (NSAttributedString *) attributedStringFromHeadersForMessage: (CWMessage *) theMessage
						showAllHeaders: (BOOL) showAllHeaders
					     useMailHeaderCell: (BOOL) useMailHeaderCell
{
  NSMutableDictionary *headerNameAttribute, *headerValueAttribute;
  NSMutableAttributedString *maStr; 

  NSMutableAttributedString *aMutableAttributedString;

  NSDictionary *allHeaders;
  NSArray *headersToShow;
  NSUInteger i, count;

  maStr = [[NSMutableAttributedString alloc] init];
  

  // Attributes for our header names
  headerNameAttribute = [[NSMutableDictionary alloc] init];

  [headerNameAttribute setObject: [NSFont headerNameFont]
		       forKey: NSFontAttributeName];


  // Attributes for our header values
  headerValueAttribute = [[NSMutableDictionary alloc] init];

  [headerValueAttribute setObject: [NSFont headerValueFont]
			forKey: NSFontAttributeName];
			
  
  // We get all the message's headers
  allHeaders = [theMessage allHeaders];
  
  // We verify which headers of the message we show show.
  if (showAllHeaders)
    {
      headersToShow = [allHeaders allKeys];
    }
  else
    {
      headersToShow = [[NSUserDefaults standardUserDefaults] objectForKey: @"SHOWNHEADERS"];
    }

  count = [headersToShow count];
  
  for (i = 0; i < count; i++)
    {
      NSString *anHeader = [headersToShow objectAtIndex: i];
      
      if ([anHeader caseInsensitiveCompare: @"Date"] == NSOrderedSame &&
	  [theMessage receivedDate])
	{
	  if ([theMessage receivedDate])
	    {
	      APPEND_HEADER(@"Date", [[theMessage receivedDate] description]);
	    }
	}
      else if ([anHeader caseInsensitiveCompare: @"From"] == NSOrderedSame &&
	       [theMessage from])
	{
	  APPEND_HEADER(@"From", [[theMessage from] stringValue]);
	}
      else if ([anHeader caseInsensitiveCompare: @"Bcc"] == NSOrderedSame)
	{
	  NSString *bccStr = [NSString stringFromRecipients: [theMessage recipients]
				       type: PantomimeBccRecipient];
	  
	  if ([bccStr length] > 0)
	    {
	      APPEND_HEADER(@"Bcc", [bccStr substringToIndex: ([bccStr length]-2)]);
	    }
	}
      else if ([anHeader caseInsensitiveCompare: @"Cc"] == NSOrderedSame)
	{
	  NSString *ccStr= [NSString stringFromRecipients: [theMessage recipients]
				     type: PantomimeCcRecipient];
	  
	  if ([ccStr length] > 0)
	    {
	      APPEND_HEADER(@"Cc", [ccStr substringToIndex: ([ccStr length]-2)]);
	    }
	}
      else if ([anHeader caseInsensitiveCompare: @"Reply-To"] == NSOrderedSame && [theMessage replyTo])
	{ 
	  NSString *replyToStr;
	  
	  replyToStr = [NSString stringFromRecipients: [theMessage replyTo]  type: 0];
	  
	  APPEND_HEADER(@"Reply-To", [replyToStr substringToIndex: ([replyToStr length]-2)]);	
	}
      else if ([anHeader caseInsensitiveCompare: @"To"] == NSOrderedSame)
	{
	  NSString *toStr = [NSString stringFromRecipients: [theMessage recipients]
				      type: PantomimeToRecipient];
	  
	  if ([toStr length] > 0)
	    {
	      APPEND_HEADER(@"To", [toStr substringToIndex: ([toStr length]-2)]);
	    }
	}
      else if ([anHeader caseInsensitiveCompare: @"Content-Type"] == NSOrderedSame)
	{
	  NSString *aString;
	  
	  if ([theMessage charset])
	    {
	      aString = [NSString stringWithFormat: @"%@; charset=%@",
				  [theMessage contentType], [theMessage charset]];
	    }
	  else
	    {
	      aString = [theMessage contentType];
	    }
	  
	  APPEND_HEADER(@"Content-Type", aString);
	}
      else
	{
	  NSArray *allKeys = [allHeaders allKeys];
	  NSString *valueString;
	  NSUInteger j, c;
	  id o;
	  
	  c = [allKeys count];
	  valueString = nil;

	  for (j = 0; j < c; j++)
	    {
	      if ([[[allKeys objectAtIndex: j] uppercaseString] isEqualToString: [anHeader uppercaseString]])
		{
		  o = [allHeaders objectForKey: [allKeys objectAtIndex: j]];
		  
		  if ([o isKindOfClass: [CWInternetAddress class]])
		    {
		      valueString = [o stringValue];
		    }
		  else
		    {
		      if ([[allKeys objectAtIndex: j] isEqualToString: @"Content-Transfer-Encoding"])
			{
			  valueString = [NSString stringValueOfTransferEncoding: [o intValue]];
			}
		      else if ([[allKeys objectAtIndex: j] isEqualToString: @"Content-Disposition"])
			{
			  if ([o intValue] == PantomimeAttachmentDisposition)
			    {
			      valueString = @"attachment";
			    }
			  else
			    {
			      valueString = @"inline";
			    }
			}
		      else
			{
			  valueString = (NSString *)o;
			}
		    }
		  break;
		}
	    }
	  
	  if (valueString)
	    {
	      APPEND_HEADER(anHeader, valueString);
	    }
	}
    } // for (..) 
    
  if (useMailHeaderCell)
    {
      NSTextAttachment *aTextAttachment;
      MailHeaderCell *theMailHeaderCell;
      
      theMailHeaderCell = [[[GNUMail lastMailWindowOnTop] windowController] mailHeaderCell];
      [theMailHeaderCell setColor: [[FilterManager singleInstance] colorForMessage: theMessage]];
      [theMailHeaderCell setAttributedStringValue: maStr];
      [theMailHeaderCell resize: nil];
      
      // We now "embed" the header cell into a NSTextAttachment object
      // so we can add it to our mutable attributed string.
      aTextAttachment = [[NSTextAttachment alloc] init];
      [aTextAttachment setAttachmentCell: theMailHeaderCell];
      
      aMutableAttributedString = [[NSMutableAttributedString alloc] init];
      
      [aMutableAttributedString appendAttributedString: 
				  [NSMutableAttributedString attributedStringWithAttachment: aTextAttachment]];
      RELEASE(aTextAttachment);
      
      //
      // If we are using message thread, we show our visualization cell.
      //
      if ([[theMessage folder] allContainers])
	{
          ThreadArcsCell *theThreadArcsCell;

          theThreadArcsCell = [[[GNUMail lastMailWindowOnTop] windowController] threadArcsCell];

	  aTextAttachment = [[NSTextAttachment alloc] init];
	  [aTextAttachment setAttachmentCell: theThreadArcsCell];
	  [aMutableAttributedString appendAttributedString: [NSMutableAttributedString attributedStringWithAttachment: aTextAttachment]];
	  RELEASE(aTextAttachment);
}
      [aMutableAttributedString appendAttributedString: [NSAttributedString attributedStringWithString: @"\n\n"
									    attributes: nil]];
    }
  else
    {
      aMutableAttributedString = [[NSMutableAttributedString alloc] init];
      [aMutableAttributedString appendAttributedString: maStr];
      [aMutableAttributedString appendAttributedString: [NSAttributedString attributedStringWithString: @"\n"
									    attributes: nil] ];
    }
  
  RELEASE(maStr);
  RELEASE(headerNameAttribute);
  RELEASE(headerValueAttribute);

  return AUTORELEASE(aMutableAttributedString);
}


//
//
//
+ (NSAttributedString *) attributedStringFromMultipartAlternative: (CWMIMEMultipart *) theMimeMultipart
						       controller: (id) theController
{
  NSString *aSubtype;
  int i, index;
  
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"DEFAULT_MULTIPART_ALTERNATIVE_TYPE"] == TYPE_HTML)
    {
      aSubtype = @"html";
    }
  else
    {
      aSubtype = @"plain";
    }
  
  index = -1;

  // We search for our preferred part (text/html or text/plain) depending on aSubtype
  for (i = 0; i < [theMimeMultipart count]; i++)
    {
      if ([[theMimeMultipart partAtIndex: i] isMIMEType: @"text"  subType: aSubtype])
	{
	  index = i;
	  break;
	}
    }

  // If we have found our preferred part, we use that one
  if (index >= 0)
    {
      return [self attributedStringFromTextPart: [theMimeMultipart partAtIndex: index]];
    }
  // We haven't, we show the first one. We don't assume that we got a text
  // part here. We could get any kind of parts.
  else
    {
      if ([theMimeMultipart count] > 0)
	{
	  return [self attributedStringFromContentForPart:[theMimeMultipart partAtIndex: 0]  controller: theController];
	}
    }
  
  return [self attributedStringFromTextPart: nil];
}


//
//
//
+ (NSAttributedString *) attributedStringFromMultipartAppleDouble: (CWMIMEMultipart *) theMimeMultipart
						       controller: (id) theController
{
  NSMutableAttributedString *aMutableAttributedString;
  NSMutableDictionary *attributes;
  CWPart *aPart;
  int i;
  
  // We create a set of attributes (base font, color red)
  attributes = [[NSMutableDictionary alloc] init];
  [attributes setObject: [NSColor redColor]
	      forKey: NSForegroundColorAttributeName];

  aMutableAttributedString = [[NSMutableAttributedString alloc] init];

  for (i = 0; i < [theMimeMultipart count]; i++)
    {
      aPart = [theMimeMultipart partAtIndex: i];
    
      if ([aPart isMIMEType: @"application"  subType: @"applefile"])
	{
	  [aMutableAttributedString appendAttributedString: [self attributedStringWithString: _(@"(Decoded Apple file follows...)")
								  attributes: attributes]];
	}
      else
	{
	  // We first add a \n between our applefile description and the 'representation' of the attachment
	  [aMutableAttributedString appendAttributedString: [self attributedStringWithString: @"\n"  attributes: nil]];
	  
	  // We add the representation of our attachment
	  [aMutableAttributedString appendAttributedString: [self attributedStringFromContentForPart: aPart  controller: theController]];
	} 
    }
  
  // We add a \n to separate everything.
  [aMutableAttributedString appendAttributedString:
			      [NSAttributedString attributedStringWithString: @"\n" attributes: nil]];
  
  RELEASE(attributes);

  return AUTORELEASE(aMutableAttributedString);
}


//
//
//
+ (NSAttributedString *) attributedStringFromTextPart: (CWPart *) thePart
{
  NSMutableDictionary *textMessageAttributes;
  NSAttributedString *aAttributedString;
  NSData *aCharset, *aData;
  NSString *aString;

  aAttributedString = nil;
  
  if (!thePart || ![thePart content])
    {
      goto done;
    }

  // Initializations of the local vars
  textMessageAttributes = [[NSMutableDictionary alloc] init];
  aData = (NSData *)[thePart content];

  //NSLog(@"data = |%@| |%@|", [aData asciiString], [thePart charset]);
  
  // Some lame MUA sends text part in 8bit without specifying a charset!
  if (([[thePart charset] isEqualToString: @"us-ascii"] || ![thePart charset]) &&
      [thePart contentTransferEncoding] == PantomimeEncoding8bit)
    {
      aCharset = [@"iso-8859-1" dataUsingEncoding: NSASCIIStringEncoding];
    }
  else
    {
      aCharset = [[thePart charset] dataUsingEncoding: NSASCIIStringEncoding];
    }

  // If our data is under the format=flowed standard, we unwrap it.
  if ([thePart format] == PantomimeFormatFlowed)
    {
      aData = [aData unwrapWithLimit: 80];
    }
  
  aString = [NSString stringWithData: aData  charset: aCharset];

  //if (!aString) NSLog(@"FIRST PASSED FAILED");

  // Some lame MUAs will generate 8-bit content w/o specifying a charset. We 
  // try with latin1 and then UTF-8.
  // WE FORCE
  if (!aString)
    {
      aString = [NSString stringWithData: aData  charset: [@"iso-8859-1" dataUsingEncoding: NSASCIIStringEncoding]];

      if (!aString)
	{
	  aString = [NSString stringWithData: aData  charset: [@"utf-8" dataUsingEncoding: NSASCIIStringEncoding]];
	}
    }
  
  //NSLog(@"aString = |%@|", aString);

  [textMessageAttributes setObject: [NSFont messageFont]  forKey: NSFontAttributeName];
    
  //
  // text/html
  //
  if ([thePart isMIMEType: @"text"  subType: @"html"])
    {
      NSData *aData;
      
#ifdef MACOSX
      aData = [aString dataUsingEncoding: [NSString encodingForPart: thePart]];      
      aAttributedString = [[NSAttributedString alloc] initWithHTML: aData
						      documentAttributes: nil];
      AUTORELEASE(aAttributedString);
#else
      aData = [CWMIMEUtility plainTextContentFromPart: thePart];
      
      //NSLog(@"Data after stripping |%@|", [aData asciiString]);

      aString = [NSString stringWithData: aData  charset: aCharset];
      
      // WE FORCE
      if (!aString)
	{
	  aString = [NSString stringWithData: aData  charset: [@"iso-8859-1" dataUsingEncoding: NSASCIIStringEncoding]];
	  
	  if (!aString)
	    {
	      aString = [NSString stringWithData: aData  charset: [@"utf-8" dataUsingEncoding: NSASCIIStringEncoding]];
	    }
	}

      //NSLog(@"String from HTML |%@|", aString);
      aAttributedString = [NSAttributedString attributedStringWithString: aString
					      attributes: textMessageAttributes];
#endif
    }
  //
  // text/enriched
  //
  else if ([thePart isMIMEType: @"text"  subType: @"enriched"])
    {
      aAttributedString = [NSAttributedString attributedStringFromTextEnrichedString: aString];
    }
  //
  // text/rtf
  //
  else if ([thePart isMIMEType: @"text"  subType: @"rtf"])
    {
      aAttributedString = [[NSAttributedString alloc] initWithRTF: aData
						      documentAttributes: NULL];
      AUTORELEASE(aAttributedString); 
    }
  //
  // We surely got a text/plain part
  //
  else
    {
      NSMutableDictionary *plainTextMessageAttributes;
      
      if ([[NSUserDefaults standardUserDefaults] 
	    objectForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] &&
	  [[NSUserDefaults standardUserDefaults] 
	    integerForKey: @"USE_FIXED_FONT_FOR_TEXT_PLAIN_MESSAGES"] == NSOnState)
	{
	  plainTextMessageAttributes = [[NSMutableDictionary alloc] init];
	  AUTORELEASE(plainTextMessageAttributes);
	  
	  [plainTextMessageAttributes setObject: [NSFont plainTextMessageFont]
				      forKey: NSFontAttributeName];
	}
      else
	{
	  plainTextMessageAttributes = textMessageAttributes;
	}
      
      aAttributedString = [NSAttributedString attributedStringWithString: aString
					      attributes: plainTextMessageAttributes];
    }

  RELEASE(textMessageAttributes);
  
 done:
  // We haven't found a text/plain part. Report this as a bug in GNUMail for not supporting
  // the other kind of parts.
  if (!aAttributedString)
    {
      //NSLog(@"data = |%@| |%@| %d", [[thePart content] asciiString], [thePart charset], [[thePart content] length]);
      aAttributedString = [NSAttributedString attributedStringWithString: 
						_(@"No text part found. Please report this bug since GNUMail doesn't support this kind of part.")
					      attributes: nil];
    }
  
  return aAttributedString;
}


//
//
//
+ (NSAttributedString *) attributedStringWithString: (NSString *) theString
					 attributes: (NSDictionary *) theAttributes
{
  if (!theAttributes)
    {
      NSAttributedString *aAttributedString;
      NSMutableDictionary *attributes;

      attributes = [[NSMutableDictionary alloc] init];
      [attributes setObject: [NSFont systemFontOfSize: 0] forKey: NSFontAttributeName];
      aAttributedString = [[self alloc] initWithString: theString   attributes: attributes];
      RELEASE(attributes);
      
      return AUTORELEASE(aAttributedString);
    }
  
  
  return AUTORELEASE([[NSAttributedString alloc] initWithString: theString attributes: theAttributes]);
}


//
//
//
#warning implement and use in the cell drawing code for the message headers
- (NSSize) sizeInRect: (NSRect) theRect
{
  if ([self size].width < theRect.size.width)
    {
      return [self size];
    }

  return NSZeroSize;
}

@end


//
//
//
@implementation NSMutableAttributedString (GNUMailMutableAttributedStringExtensions)

- (void) format
{
  NSString *aString, *aFilename;
  NSMutableArray *allRanges;
  NSRange aRange, maxRange;
  
  int c, i, len, index, offset;
  id attachment, cell;
  
  allRanges = [[NSMutableArray alloc] init];
  len = [self length];
  index = 0;
  
  maxRange = NSMakeRange(0, len);

  while (index < len)
    {
      attachment = [self attribute: NSAttachmentAttributeName
			 atIndex: index
			 longestEffectiveRange: &aRange
			 inRange: maxRange];
      
      if (attachment)
	{ 
	  cell = [attachment attachmentCell];
	  
	  if ([cell respondsToSelector: @selector(part)])
	    {
	      [allRanges addObject: [NSArray arrayWithObjects: attachment, [NSValue valueWithRange: aRange], nil]];
	    }
	}
      
      index = NSMaxRange(aRange);
      maxRange = NSMakeRange(index, len-index);
    }

  aString = [self string];
  c = [allRanges count];
  offset = 0;

  for (i = c-1; i >= 0; i--)
    {
      attachment = [[allRanges objectAtIndex: i] objectAtIndex: 0];
      cell = [attachment attachmentCell];
      aFilename = ([[cell part] filename] ? (id)[[cell part] filename] : (id)@"unknown");

      aRange = [aString rangeOfString: [NSString stringWithFormat: @"<<%@>>", aFilename]
			options: NSBackwardsSearch];
      
      if (aRange.location == NSNotFound)
        {
          aRange = [aString rangeOfString: [NSString stringWithFormat: @"<%@>", aFilename]
			    options: NSBackwardsSearch];
        }
      
      if (aRange.length)
        {
	  NSRange r;

	  r = [[[allRanges objectAtIndex: i] lastObject] rangeValue];
	  r.location = r.location - offset;
	  
	  [self deleteCharactersInRange: r];
	  [self replaceCharactersInRange: aRange
		withAttributedString: [NSAttributedString attributedStringWithAttachment: attachment]];

	  offset = offset + aRange.length - 1;
        }
    }

  RELEASE(allRanges);
}


//
//
//
- (void) highlightAndActivateURL
{
  NSRange searchRange, foundRange;
  NSString *aString, *aPrefix;
  NSEnumerator *theEnumerator;
  NSArray *allPrefixes;

  int len;
  char c;

  allPrefixes = [NSArray arrayWithObjects: @"www.", @"http://", @"https://", @"ftp://", @"file://", nil];
  theEnumerator = [allPrefixes objectEnumerator];
    
  aString = [self string];
  len = [aString length];

  while ((aPrefix = (NSString *)[theEnumerator nextObject]))
    {
      searchRange = NSMakeRange(0, len);
      do
	{
	  foundRange = [aString rangeOfString: aPrefix
				options: 0
				range: searchRange];
	  
	  // If we found an URL...
	  if (foundRange.length > 0)
	    {
	      NSDictionary *linkAttributes;
	      NSURL *anURL;
	      int end;

	      // Restrict the searchRange so that it won't find the same string again
	      searchRange.location = end = NSMaxRange(foundRange);
	      searchRange.length = len - searchRange.location;
	      
	      // We assume the URL ends with whitespace
	      while ((end < len) && ((c = [aString characterAtIndex: end]) != '\n' && c != ' ' && c != '\t'))
		{
		  end++;
		}

	      // Set foundRange's length to the length of the URL
	      foundRange.length = end - foundRange.location;

	      // If our URL is ended with a ".", "!", "," ">", or ")", trim it
	      c = [aString characterAtIndex: (end - 1)];
	      
	      if (c == '.' || c == '!' || c == ',' || c == '?' || c == '>'
	      	  || c == ')')
		{
		  foundRange.length--;
		}

	      // We create our URL object from our substring
              // if we found just "www", we prepend "http://"
              if ([aPrefix caseInsensitiveCompare: @"www."] == NSOrderedSame)
		{
		  anURL = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@", 
							  [aString substringWithRange: foundRange]]];
		}
	      else
		{
		  anURL = [NSURL URLWithString: [aString substringWithRange: foundRange]];
		}
	      
	      // Make the link attributes
	      linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys: anURL, NSLinkAttributeName,
					     [NSNumber numberWithInt: NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
					     [NSColor blueColor], NSForegroundColorAttributeName,
					     NULL];
	      
	      // Finally, apply those attributes to the URL in the text
	      [self addAttributes: linkAttributes  range: foundRange];
	    }
	  
	} while (foundRange.length != 0);
    }
}


//
//
//
- (void) quote
{
  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"COLOR_QUOTED_TEXT"  default: NSOnState] == NSOffState)
    {
      return;
    }
  else
    {   
      NSDictionary *attributes;
      NSString *aString;
 
      NSUInteger i, j;
      NSUInteger level;
      NSUInteger len;
     
      aString = [self string];
      len = [aString length];
      i = j = 0;
      
      for (; i < len; i++)
	{
	  if ([aString characterAtIndex: i] == '\n')
	    {
	      if (i > j)
		{
		  level = levelFromString(aString, j, i);
		  
		  if (level)
		    {
		      attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
						   [NSColor colorForLevel: level],
						 NSForegroundColorAttributeName, 
						 nil];
		      [self addAttributes: attributes  range: NSMakeRange(j,i-j)];
		    }
		}
	      j = i+1;
	    }
	}
      
      if (i > j)
	{
	  level = levelFromString(aString, j, i);

	  if (level)
	    {
	      attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
					   [NSColor colorForLevel: level],
					 NSForegroundColorAttributeName, 
					 nil];
	      [self addAttributes: attributes  range: NSMakeRange(j,i-j)];
	    }
	}
    }
}

@end


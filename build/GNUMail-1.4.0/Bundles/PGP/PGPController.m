/*
**  PGPController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte, Tomio Arisaka
**  Copyright (C) 2017      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Tomio Arisaka <tomio-a@max.hi-ho.ne.jp>
**          Riccardo Mottola <rm@gnu.org>
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "PGPController.h"
#import "PGPViewController.h"

// GNUMail headers
#import "Constants.h"
#import "MailWindowController.h"
#import "NSAttributedString+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "PasswordPanelController.h"
#import "Utilities.h"

// Pantomime headers
#import <Pantomime/CWConstants.h>
#import <Pantomime/CWInternetAddress.h>
#import <Pantomime/CWMessage.h>
#import <Pantomime/CWMIMEMultipart.h>
#import <Pantomime/CWMIMEUtility.h>
#import <Pantomime/CWParser.h>
#import <Pantomime/CWPart.h>
#import <Pantomime/NSData+Extensions.h>
#import <Pantomime/NSFileManager+Extensions.h>
#import <Pantomime/NSString+Extensions.h>

static PGPController *singleInstance = nil;


#define CHECK_FOR_RAW_SOURCE() ({ \
  if (![theMessage rawSource]) \
    { \
      [theMessage setProperty: theTextView  forKey: @"NSTextView"]; \
      [theMessage setProperty: [NSNumber numberWithBool: YES]  forKey: @"Loading"]; \
      return; \
    } \
})

//
// Private methods
//
@interface PGPController (Private)
- (BOOL) _analyseTaskOutput: (NSMutableData *) theMutableData
                    message: (NSMutableString *) theMessage;

- (void) _decryptPart: (CWPart *) thePart
            multipart: (BOOL) aBOOL
              message: (CWMessage *) theMessage;

- (void) _verifyPart: (CWPart *) thePart 
             allPart: (CWPart *) allPart 
           rawSource: (NSData *) rawData 
       signaturePart: (CWPart *) signPart 
             message: (CWMessage *) theMessage;

- (CWMessage *) _encryptMessage: (CWMessage *) theMessage
                      multipart: (BOOL) aBOOL;

- (NSString *) _passphraseForID: (NSString *) theID;

- (void) _tick;
@end



//
// View class
//
@interface PGPImageView : NSView
{
  @private
    NSImage *_image;
}
- (NSImage *) image;
- (void) setImage: (NSImage *) theImage;
@end

@implementation PGPImageView

- (NSImage *) image
{
  return _image;
}

- (void) setImage: (NSImage *) theImage
{
  // No need to retain the image here since it's retained
  // in PGPController
  _image = theImage;
}

@end


//
// Passphrase class
//
@interface Passphrase : NSObject
{
  @private
    NSString *_value;
    NSDate *_date;
}
- (id) initWithValue: (NSString *) theValue;
- (NSString *) value;
- (void) setValue: (NSString *) theValue;
- (NSDate *) date;
- (void) setDate: (NSDate *) theDate;
@end

@implementation Passphrase

- (id) initWithValue: (NSString *) theValue
{
  self = [super init];

  [self setValue: theValue];
  [self setDate: [NSDate date]];

  return self;
}

- (void) dealloc
{
  RELEASE(_value);
  RELEASE(_date);
  [super dealloc];
}

- (NSString *) value
{
  return _value;
}

- (void) setValue: (NSString *) theValue
{
  ASSIGN(_value, theValue);
}

- (NSDate *) date
{
  return _date;
}

- (void) setDate: (NSDate *) theDate
{
  ASSIGN(_date, theDate);
}
@end


//
//
//
@implementation PGPController

- (id) initWithOwner: (id) theOwner
{
  self = [super init];
  if (self)
    {
      NSBundle *aBundle;
   
      owner = theOwner;
 
      aBundle = [NSBundle bundleForClass: [self class]];
  
      resourcePath = [aBundle resourcePath];
      RETAIN(resourcePath);

      sImage = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/signed_80.tiff", resourcePath]];
      eImage = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/encrypted_80.tiff", resourcePath]];
      seImage = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/signed+encrypted_80.tiff", resourcePath]];
  
      view = [[PGPImageView alloc] init];

      // We create our passphrase cache
      passphraseCache = [[NSMutableDictionary alloc] init];

      [self updateAndRestartTimer];

      // We register for our notification
      [[NSNotificationCenter defaultCenter]
       addObserver: self
       selector: @selector(_messageFetchCompleted:)
       name: @"PantomimeMessageFetchCompleted"
       object: nil];
    }
  return self;
}


//
//
//
- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];

  RELEASE(resourcePath);

  RELEASE(view);

  RELEASE(sImage);
  RELEASE(eImage);
  RELEASE(seImage);

  RELEASE(encrypt);
  RELEASE(sign);
  
  RELEASE(passphraseCache);
  
  if (timer)
    {
      [timer invalidate];
      RELEASE(timer);
    }

  [super dealloc];
}


//
//
//
+ (id) singleInstance
{
  if (!singleInstance)
    {
      singleInstance = [[PGPController alloc] initWithOwner: nil];
    }

  return singleInstance;
}


//
// access / mutation methods
//
- (NSString *) name
{
  return @"PGP";
}


//
//
//
- (NSString *) description
{
  return @"This is the PGP/GPG bundle for GNUMail.";
}


//
//
//
- (NSString *) gnumailBundleVersion
{
  return @"v1.0.0";
}

- (NSString *) version
{
  return [self gnumailBundleVersion];
}


//
//
//
- (void) setOwner: (id) theOwner
{
  owner = theOwner;
}


//
// UI elements
//
- (BOOL) hasPreferencesPanel
{
  return YES;
}


//
//
//
- (PreferencesModule *) preferencesModule
{
  return [PGPViewController singleInstance];
}


//
//
//
- (BOOL) hasComposeViewAccessory
{
  return YES;
}


//
//
//
- (id) composeViewAccessory
{
  NSImage *icon;
  NSView *aView;
  
  aView = [[NSView alloc] initWithFrame: NSMakeRect(0,0,68,32)];

  //
  // Encrypt / clear button
  //
  encrypt = [[NSButton alloc] initWithFrame: NSMakeRect(0,0,32,32)];
  [encrypt setImagePosition: NSImageOnly];
  [encrypt setBordered: NO];
  icon = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/clear_20.tiff", resourcePath]];
  [encrypt setImage: icon];
  RELEASE(icon);

  [encrypt setTarget: self];
  [encrypt setAction: @selector(encryptClicked:)];
  [encrypt setTag: NOT_ENCRYPTED];

  [aView addSubview: encrypt];

  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_ALWAYS_ENCRYPT"  default: NSOffState] == NSOnState)
    {
      [self encryptClicked: nil];
    }
  
  //
  // Signed / Unsigned button
  //
  sign = [[NSButton alloc] initWithFrame: NSMakeRect(36,0,32,32)];
  [sign setImagePosition: NSImageOnly];
  [sign setBordered: NO];
  icon = [[NSImage alloc] initWithContentsOfFile: [NSString stringWithFormat: @"%@/unsigned_20.tiff", resourcePath]];
  [sign setImage: icon];
  RELEASE(icon);

  [sign setTarget: self];
  [sign setAction: @selector(signClicked:)];
  [sign setTag: NOT_SIGNED];

  [aView addSubview: sign];

  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_ALWAYS_SIGN"  default: NSOffState] == NSOnState)
    {
      [self signClicked: nil];
    }
											   
  return AUTORELEASE(aView);
}


//
//
//
- (BOOL) hasViewingViewAccessory
{
  return YES;
}


//
//
//
- (id) viewingViewAccessory
{  
  return view;
}


//
//
//
- (enum ViewingViewType) viewingViewAccessoryType
{
  return ViewingViewTypeHeaderCell;
}

//
//
//
- (void) viewingViewAccessoryWillBeRemovedFromSuperview: (id) theView
{

}


//
//
//
- (void) setCurrentSuperview: (NSView *) theView
{
  superview = theView;
}


//
//
//
- (NSArray *) submenuForMenu: (NSMenu *) theMenu
{
  return nil;
}


//
//
//
- (NSArray *) menuItemsForMenu: (NSMenu *) theMenu
{
  return nil;
}



//
// action methods
//
- (IBAction) encryptClicked: (id) sender
{
  NSImage *icon;

  if ([encrypt tag] == NOT_ENCRYPTED)
    {
      [encrypt setTag: ENCRYPTED];
     
      icon = [[NSImage alloc] initWithContentsOfFile: 
				[NSString stringWithFormat: @"%@/encrypted_20.tiff", resourcePath]];
      [encrypt setImage: icon];
      RELEASE(icon);
    }
  else
    {
      [encrypt setTag: NOT_ENCRYPTED];

      icon = [[NSImage alloc] initWithContentsOfFile: 
				[NSString stringWithFormat: @"%@/clear_20.tiff", resourcePath]];
      [encrypt setImage: icon];
      RELEASE(icon);
    }
}


//
//
//
- (IBAction) signClicked: (id) sender
{
  NSImage *icon;
  
  if ([sign tag] == NOT_SIGNED)
    {
      [sign setTag: SIGNED];

      icon = [[NSImage alloc] initWithContentsOfFile: 
				[NSString stringWithFormat: @"%@/signed_20.tiff", resourcePath]];
      [sign setImage: icon];
      RELEASE(icon);
    }
  else
    {
      [sign setTag: NOT_SIGNED];

      icon = [[NSImage alloc] initWithContentsOfFile: 
				[NSString stringWithFormat: @"%@/unsigned_20.tiff", resourcePath]];
      [sign setImage: icon];
      RELEASE(icon);
    }
}


//
// other methods
//
- (void) updateAndRestartTimer
{
  if (timer)
    {
      [timer invalidate];
      DESTROY(timer);
    }

  if ([[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY"] == NSOnState)
    {
      timer = [NSTimer scheduledTimerWithTimeInterval: 60*[[NSUserDefaults standardUserDefaults]
							    integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY_VALUE"]
		       target: self
		       selector: @selector(_tick)
		       userInfo: nil
		       repeats: YES];

      RETAIN(timer);
    }
}


//
// Pantomime related methods
//
- (CWMessage *) messageWasEncoded: (CWMessage *) theMessage
{  
  CWMessage *aMessage;

  // We first verify if we must at least sign OR encrypt
  if ([sign tag] == NOT_SIGNED && [encrypt tag] == NOT_ENCRYPTED)
    {
      return theMessage;
    }
  
  // If our content isn't a multipart
  if ([theMessage isMIMEType: @"text"  subType: @"*"])
    {
      if ([[NSUserDefaults standardUserDefaults] boolForKey: @"PGPBUNDLE_ALWAYS_MULTIPART"])
	{
	  CWMIMEMultipart *aMimeMultipart;
	  NSData  *aBoundaryData, *aData;
	  CWPart *aPart;

	  NSRange aRange;
	  
	  // We create our new multipart object
	  aMimeMultipart = [[CWMIMEMultipart alloc] init];
	  
	  // We add our message part
	  aPart = [[CWPart alloc] init];
	  [aPart setContentTransferEncoding: [theMessage contentTransferEncoding]];
	  [aPart setContentType: [theMessage contentType]];
	  [aPart setCharset: [theMessage charset]];
	  aData = [theMessage dataValue];
	  aRange = [aData rangeOfCString: "\n\n"];
	  aData = [aData subdataFromIndex: (aRange.location + 2)];
	  
	  if ([theMessage contentTransferEncoding] == PantomimeEncodingQuotedPrintable)
	    {
	      aData = [aData decodeQuotedPrintableInHeader: NO];
	    }
	  else if ([theMessage contentTransferEncoding] == PantomimeEncodingBase64)
	    {
	      aData = [aData decodeBase64];
	    }
	  
	  [aPart setContent: aData];
	  [aPart setSize: [aData length]];
	  
	  [aMimeMultipart addPart: aPart];
	  RELEASE(aPart);
	  
	  // We add our dummy part
	  aPart = [[CWPart alloc] init];
	  [aPart setContentTransferEncoding: PantomimeEncodingNone];
	  [aPart setContentType: @"text/plain"];
	  [aPart setCharset: @"us-ascii"];
	  [aPart setContentDisposition: PantomimeAttachmentDisposition];
	  [aPart setFilename: @"RFC3156.txt"];
	  [aPart setContent: [@"RFC3156 defines security multipart formats for MIME with OpenPGP." dataUsingEncoding: NSASCIIStringEncoding]];
	  [aPart setSize: [(NSData *)[aPart content] length]];
	  [aMimeMultipart addPart: aPart];
	  RELEASE(aPart);
	  
	  // We generate a new boundary
	  aBoundaryData = [CWMIMEUtility globallyUniqueBoundary];
	  
	  // We set the new boundary, the new Content-Type and the Content-Transfer-Encoding to our message
	  [theMessage setBoundary: aBoundaryData];
	  [theMessage setContentType: @"multipart/mixed"];
	  [theMessage setContentTransferEncoding: PantomimeEncodingNone];
	  
	  // We finally set the new multipart content
	  [theMessage setContent: aMimeMultipart];
	  RELEASE(aMimeMultipart);
	  
	  // We got a multipart content!
	  aMessage = [self _encryptMessage: theMessage  multipart: YES];
	  
	  return aMessage;
	}
      
      aMessage = [self _encryptMessage: theMessage  multipart: NO];
    }
  else
    {
      // We got a multipart content!
      aMessage = [self _encryptMessage: theMessage  multipart: YES];
    }

  return aMessage;
}


//
//
//
- (void) messageWasDisplayed: (CWMessage *) theMessage
		      inView: (NSTextView *) theTextView
{
  id o;

  o = [theMessage propertyForKey: @"Loading"];

  if (o && [o boolValue])
    {
      [[theTextView textStorage] deleteCharactersInRange: NSMakeRange(0, [[theTextView textStorage] length])];
      [[theTextView textStorage] insertAttributedString: [NSAttributedString attributedStringFromHeadersForMessage: theMessage
									     showAllHeaders: NO
									     useMailHeaderCell: YES]
				 atIndex: 0];
      [[theTextView textStorage] appendAttributedString: [NSAttributedString attributedStringWithString: _(@"Loading message...")
									     attributes: nil]];
    }
}


//
// FIXME: Consider the Content-Type's protocol!
//
- (void) messageWillBeDisplayed: (CWMessage *) theMessage
                         inView: (NSTextView *) theTextView
{
  //
  // We DO NOT check if the message's content IS NOT a NSString. This could
  // happen if the decoding op in Pantomime failed.
  //  
  if ([theMessage content] && 
      [[theMessage content] isKindOfClass: [NSData class]] &&
      [theMessage isMIMEType: @"text"  subType: @"plain"])
    {
      if ([(NSData *)[theMessage content] hasCPrefix: "-----BEGIN PGP MESSAGE-----"] || 
	  [(NSData *)[theMessage content] hasCPrefix: "-----BEGIN PGP SIGNED MESSAGE-----"])
	{
	  CHECK_FOR_RAW_SOURCE();
	  [self _decryptPart: theMessage  multipart: NO  message: theMessage];
	}
    }
  //
  // VERIFY IF:
  //             multipart/encrypted
  //
  //             contains exactly TWO parts: application/pgp-encrypted
  //                                         application/octet-stream 
  //
  // 
  else if ([theMessage isMIMEType: @"multipart"  subType: @"encrypted"])
    {
      CWMIMEMultipart *aMimeMultipart;
      int i;

      CHECK_FOR_RAW_SOURCE();
     
      // We search for our octet-stream part.
      aMimeMultipart = (CWMIMEMultipart *)[theMessage content];

      for (i = ([aMimeMultipart count] - 1); i >= 0; i--)
	{
	  CWPart *aPart;
	  
	  aPart = [aMimeMultipart partAtIndex: i];
       
	  if ([aPart isMIMEType: @"application"  subType: @"octet-stream"])
	    {
	      [self _decryptPart: aPart  multipart: YES  message: theMessage];
	    }
	  else if ([aPart isMIMEType: @"application"  subType: @"pgp-encrypted"])
	    {
	      [aMimeMultipart removePart: aPart];
	    }
	}
    }
  //
  // VERIFY IF:
  //             multipart/signed
  // 
  else if ([theMessage isMIMEType: @"multipart"  subType: @"signed"])
    {
      CWMIMEMultipart *aMimeMultipart;
      int i;
      
      CHECK_FOR_RAW_SOURCE();

      aMimeMultipart = (CWMIMEMultipart *)[theMessage content];
      
      for (i = 1; i < [aMimeMultipart count]; i++)
	{
	  CWPart  *aPart;

	  aPart = [aMimeMultipart partAtIndex: i];
	  
	  if ([aPart isMIMEType: @"application"  subType: @"pgp-signature"])
	    {
	      [self _verifyPart: [aMimeMultipart partAtIndex: 0]
		    allPart: nil
		    rawSource: nil
		    signaturePart: aPart
		    message: theMessage];
	      [aMimeMultipart removePart: aPart];
	      break;
	    }
        }
    }

  if ([theMessage propertyForKey: @"CONTENT-STATUS"] &&
      [[theMessage propertyForKey: @"CONTENT-STATUS"] intValue] == ENCRYPTED)
    {
      [view setImage: eImage];
    }
  else if ([theMessage propertyForKey: @"CONTENT-STATUS"] &&
	   [[theMessage propertyForKey: @"CONTENT-STATUS"] intValue] == SIGNED)
    {
      [view setImage: sImage];
    }
  else if ([theMessage propertyForKey: @"CONTENT-STATUS"] &&
	   [[theMessage propertyForKey: @"CONTENT-STATUS"] intValue] == SIGNED_AND_ENCRYPTED)
    {
      [view setImage: seImage];
    }
  else
    {
      [view setImage: nil];
    }
}

@end



//
// Private methods
//
@implementation PGPController (Private)

//
// When this method is called, all results to --status-fd=2 (stderr)
// have been produced by the GPG task. So, we simply read it,
// and toss the irrelevant information.
//
- (BOOL) _analyseTaskOutput: (NSMutableData *) theMutableData
		    message: (NSMutableString *) theMessage
{
  NSArray *allLines;
  BOOL aBOOL;
  int i, c;
  
  allLines = [theMutableData componentsSeparatedByCString: "\n"];
  c = [allLines count];
  aBOOL = YES;
  
  for (i = 0; i < c; i++)
    {
      if ([[allLines objectAtIndex: i] hasCPrefix: "[GNUPG:] "])
	{
	  NSString *aString;
	  
	  aString = [[NSString alloc] initWithData: [[allLines objectAtIndex: i] subdataFromIndex: 9]
				      encoding: NSUTF8StringEncoding]; 
	  
	  NSLog(@"READ = |%@|", aString);
	  
	  // We analyse our task's output.
	  if ([aString hasPrefix: @"BAD_PASSPHRASE"])
	    {
	      [theMessage appendString: _(@"\nThe supplied passphrase was wrong or not given")];
	      aBOOL = NO;
	      RELEASE(aString);
	      break;
	    }
	  else if ([aString hasPrefix: @"DECRYPTION_FAILED"])
	    {
	      [theMessage appendString: _(@"\nWrong passphrase (or something else)")];
	      aBOOL = NO;
		  RELEASE(aString);
	      break;
	    }
	  else if ([aString hasPrefix: @"NODATA"])
	    {
	      [theMessage appendString: _(@"\nNo data has been found")];
	      aBOOL = NO;
		  RELEASE(aString);
	      break;
	    }
	  else if ([aString hasPrefix: @"SIGEXPIRED"] ||  [aString hasPrefix: @"KEYEXPIRED"])
	    {
	      [theMessage appendString: _(@"\nYour key is expired. You must generate a new one\nbefore trying to send again any signed or encrypted messages.")];
	      aBOOL = NO;
		  RELEASE(aString);
	      break;
	    }
	  // We check errors for the signature
	  else if ([aString hasPrefix: @"BADSIG"])
	    {
	      [theMessage appendString:_(@"\nThe signature has NOT been VERIFIED okay.")];
	      aBOOL = NO;
		  RELEASE(aString);
	      break;
		}
	  else if ([aString hasPrefix: @"ERRSIG"])
	    {
	      [theMessage appendString:_(@"\nIt was NOT possible to CHECK the signature.\nThis may be caused by a missing public key or an unsupported algorithm.")];
	      aBOOL = NO;
          RELEASE(aString);
	      break;
	    }	  
	  RELEASE(aString);
	} // if ( [[allLines objectAtIndex: i] hasCPrefix: "[GNUPG:] "] )
      else
	{
	  NSArray *aLanguagesArray;

	  aLanguagesArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey: @"AppleLanguages"];

	  // We check the user's preferred language.
	  // FIXME: Use the right encoding depending of the user's preferred language
	  //        or simply use UTF8?
	  if ([(NSString *)[aLanguagesArray objectAtIndex: 0] isEqualToString: @"Japanese"])
	    {
	      NSString *aString;
	      
	      aString = [[NSString alloc] initWithData: [allLines objectAtIndex: i]
					  encoding: NSJapaneseEUCStringEncoding];
	      [theMessage appendFormat: @"\n%@", aString];
	      RELEASE(aString);
            }
	  else
	    {
	      [theMessage appendFormat: @"\n%@", [[allLines objectAtIndex: i] asciiString]];
            }
	}
    }
  
  return aBOOL;
}


//
// GPG commands:
//
//  --batch  Use batch mode.  Never ask, do not allow  inter­
//           active commands.
//
//  --status-fd n
//           Write   special   status  strings  to  the  file
//           descriptor n.  See the file DETAILS in the docu­
//           mentation for a listing of them.
//
//  --passphrase-fd n
//           Read the passphrase from file descriptor  n.  If
//           you  use  0  for  n, the passphrase will be read
//           from stdin.     This can only be  used  if  only
//           one  passphrase  is  supplied.   Don't  use this
//           option if you can avoid it.
//
- (void) _decryptPart: (CWPart *) thePart
	    multipart: (BOOL) aBOOL
	      message: (CWMessage *) theMessage

{	    
  NSString *aLaunchPath, *inFilename, *outFilename, *aPassphrase, *aUserID;
  NSPipe *standardInput, *standardError;
  NSMutableString *aWarningMessage;
  NSMutableData *aMutableData;
  NSMutableArray *arguments;
  NSTask *aTask;
  BOOL pinentryLoopback = YES;
  
  BOOL is_signed_only;
  char *s1, *s2;
  
  // We generate temporary filenames
  s1 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  inFilename = [NSString stringWithCString: s1];
  
  s2 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  outFilename = [NSString stringWithFormat: @"%s.out", s2];
  
  //
  // We get our User ID (E-Mail address only). We use it to obtain the GPG passphrase:
  //
  if (![[NSUserDefaults standardUserDefaults] objectForKey: @"PGPBUNDLE_USE_FROM_FOR_SIGNING"] ||
      [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_USE_FROM_FOR_SIGNING"] == NSOnState)
    {
      aUserID = [[theMessage from] address];
    }
  else
    {
      aUserID = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_USER_EMAIL_ADDRESS"];
    }
  

  // We set the right property, depending on the content's prefix
  if ([(NSData *)[thePart content] hasCPrefix: "-----BEGIN PGP MESSAGE-----"])
    {
      [theMessage setProperty: [NSNumber numberWithInt: ENCRYPTED]  forKey: @"CONTENT-STATUS"];
      is_signed_only = NO;
    }
  else
    {
      [theMessage setProperty: [NSNumber numberWithInt: SIGNED]  forKey: @"CONTENT-STATUS"];
      is_signed_only = YES;
    }
  

  // We first get our launch path
  aLaunchPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_GPG_PATH"];

  // Check if we should enable pinentry loopback
  pinentryLoopback = [[NSUserDefaults standardUserDefaults] boolForKey: @"PGPBUNDLE_GPG_PINELOOP"];
  
  if (!aLaunchPath || [aLaunchPath length] == 0)
    {
#ifdef MACOSX
      aLaunchPath = @"/usr/local/bin/gpg";
#else
      aLaunchPath = @"/usr/bin/gpg";
#endif
    }

  // We now verify if our launch path exists and is executable
  if (![[NSFileManager defaultManager] isExecutableFileAtPath: aLaunchPath])
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"The file %@ does not exist or is not executable"),
                      _(@"OK"),   // default
                      NULL,       // alternate
                      NULL,
		      aLaunchPath);
      return;
    }
  
  // We create our task object
  aTask = [[NSTask alloc] init];
  [aTask setLaunchPath: aLaunchPath];  
    
  //
  // We initialize our basic arguments
  //
  arguments = [[NSMutableArray alloc] initWithObjects:  @"--batch", 
				      @"--no-tty",
				      @"--status-fd",
				      @"2",
				      @"-o",
				      outFilename,
				      nil];
  if (pinentryLoopback)
    {
      [arguments addObject: @"--pinentry-mode"];
      [arguments addObject: @"loopback" ];
    }

  
  // We write our mail content to a temporary file
  [(NSData *)[thePart content] writeToFile: inFilename  atomically: YES];
  [[NSFileManager defaultManager] enforceMode: 0600  atPath: inFilename];
  
  if (!is_signed_only)
    {      
      [arguments addObject: @"--passphrase-fd"];
      [arguments addObject: @"0"];

      // We create our standard input handle pipe
      standardInput = [NSPipe pipe];
      
      // We write our passphrase on the pipe
      aPassphrase = [self _passphraseForID: aUserID];  // ex: ludovic@Sophos.ca
      [[standardInput fileHandleForWriting] writeData:
					      [aPassphrase dataUsingEncoding:
							     NSASCIIStringEncoding]];
      [[standardInput fileHandleForWriting] closeFile];
      
      // We set the stdin / stdout
      [aTask setStandardInput: standardInput];
    }

  // We add the extra arguments, to decrypt the filename instead of reading
  // everything on stdin
  [arguments addObject: @"--decrypt"];
  [arguments addObject: inFilename];
  
  // We set our task's standard error
  standardError = [NSPipe pipe];
  [aTask setStandardError: standardError];
  
  // We set our task's arguments
  [aTask setArguments: arguments];
  RELEASE(arguments);

  // We create our mutable data and string object
  aWarningMessage = [[NSMutableString alloc]
		      initWithString: _(@"Decryption failed due the following reason(s):\n")];
  aMutableData = [[NSMutableData alloc] init];

  // We lauch our task
  [aTask launch];
  
  // While the task is dunning, we accumulate the infoz read on stderr
  // into aMutableData.
  while ([aTask isRunning])
    {
      [aMutableData appendData: [[standardError fileHandleForReading] availableData]];
    }
  
  
  // We analyse the output of our GPG task to stderr. If it the decryption
  // failed, we do some cleanups.
  if (![self _analyseTaskOutput: aMutableData  message: aWarningMessage])
    {
      // We show the reason why decryption failed
      NSRunAlertPanel(_(@"Error!"),
		      aWarningMessage,
                      _(@"OK"),   // default
                      NULL,       // alternate
                      NULL);
      

      // FIXME: move to the _analyseTaskOutput:: method
      // We remove the passphrase for this ID
      [passphraseCache removeObjectForKey: aUserID];
      
      // We remove our temporary files and we free some vars
      [[NSFileManager defaultManager] removeFileAtPath: inFilename  handler: nil];      
      [[NSFileManager defaultManager] removeFileAtPath: outFilename  handler: nil];     
      free(s1);
      free(s2);
      
      RELEASE(aMutableData);
      RELEASE(aWarningMessage);
      RELEASE(aTask);
      
      return;
    }
  else
    {	
      // We check the signed message
      // We check the decrypted PGP-Combined-message whether it has a good signature or not.
      // We check the decrypted OpenPGP-Combined-message whether it has a good signature or not.
      if ([theMessage propertyForKey: @"CONTENT-STATUS"])
	{
	  NSRange aRange;
	  int status;
	  
	  aRange = [aMutableData rangeOfCString: "GOODSIG"  options: NSCaseInsensitiveSearch];
	  status = [[theMessage propertyForKey: @"CONTENT-STATUS"] intValue];
	  
	  if (status == ENCRYPTED)
	    {
	      if (aRange.length > 0)
		{
		  [theMessage setProperty: [NSNumber numberWithInt: SIGNED_AND_ENCRYPTED]  forKey: @"CONTENT-STATUS"];
		}
	    }
	  else if (status == SIGNED)
	    {
	      if (aRange.length == 0)
		{
		  [theMessage setProperty: [NSNumber numberWithInt: NOT_SIGNED]  forKey: @"CONTENT-STATUS"];
		}
	    }
	}
    }
   
  RELEASE(aMutableData);
  RELEASE(aWarningMessage);

  //
  // Decryption is done. We now set the new content of the message
  // by replacing the actual one.
  //
  if (!aBOOL)
    {
      [thePart setContent: [NSData dataWithContentsOfFile: outFilename]];
    }
  else
    {
      NSMutableData *aMutableData;
      NSData *aData;
      NSRange aRange, sRange, eRange;
      BOOL noHeader;

      // We replace all occurences of \r\n by \n
      aMutableData = [[NSMutableData alloc] initWithData: [NSData dataWithContentsOfFile: outFilename]];
      [aMutableData replaceCRLFWithLF];
      
      // We unfold all lines
      aData = [aMutableData unfoldLines];
      noHeader = NO;
	
      //
      // We grab only the headers we are interested in to and we parse them.
      // We parse and set the Content-Transfer-Encoding
      //
      sRange = [aData rangeOfCString: "Content-Transfer-Encoding:"  options: NSCaseInsensitiveSearch];
      
      if (sRange.length > 0)
	{
	  sRange.length = [aData length] - sRange.location;
	  eRange = [aData rangeOfCString: "\n"  options: 0  range: sRange];
	  aRange.location = sRange.location;
	  aRange.length = eRange.location - sRange.location;
	  [CWParser parseContentTransferEncoding: [aData subdataWithRange: aRange]  inPart: thePart];
	}
      else
	{
	  [thePart setContentTransferEncoding: PantomimeEncodingNone];
	}
      
      //
      // We parse and set the Content-Type & boundary
      //
      sRange = [aData rangeOfCString:"Content-Type:"  options: NSCaseInsensitiveSearch];
      
      if (sRange.length > 0)
	{
	  NSData *cData;
	  
	  sRange.length = [aData length] - sRange.location;
	  eRange = [aData rangeOfCString: "\n"  options: 0  range: sRange];
	  aRange.location = sRange.location;
	  aRange.length = eRange.location - sRange.location + 1;
	  [CWParser parseContentType: [aData subdataWithRange: aRange]  inPart: thePart];
	  
	  // We set the protocol
	  eRange = [aData rangeOfCString: "application/pgp-signature"  options: NSCaseInsensitiveSearch];
	  
	  if (eRange.length > 0)
	    {
	      [thePart setProtocol: [@"application/pgp-signature"
				      dataUsingEncoding: NSASCIIStringEncoding]];
	    }
	  
	  // We parse the boundary and remove the quotation-mark in it
	  cData = [thePart boundary];
	  eRange = [cData rangeOfCString: "\""  options: NSCaseInsensitiveSearch];
	  
	  if ((eRange.location == 0) && (eRange.length > 0))
	    {
	      cData = [cData subdataFromIndex: 1];
	      eRange = [cData rangeOfCString: "\""  options: NSCaseInsensitiveSearch];
	      
	      if ( eRange.length > 0 )
		{
		  [thePart setBoundary: [cData subdataToIndex: eRange.location]];
		}
	    }
	}
      else
	{
	  [thePart setContentType: @"text/plain"];
	  noHeader = YES;
	}
      
      // We set the raw content
      aRange = [aData rangeOfCString: "\n\n"];	// The body is separated from the header by an empty line
      
      if ((aRange.length > 0) && !noHeader)
	{
	  if ([[thePart boundary] length] > 0)
	    {
	      aRange = [aData rangeOfCString: [[NSString stringWithFormat: @"--%s", [[thePart boundary] cString]] cString]];
	    }
	  else
	    {
	      aRange.location += 2;
	    }
	}
      else
	{
	  aRange.location = 0;
	}
      
      [CWMIMEUtility setContentFromRawSource: [aData subdataFromIndex: aRange.location]
		     inPart: thePart];
      
      //
      // We must check encapsulated-signed-message.
      //
      if ([thePart isMIMEType: @"multipart"  subType: @"signed"])
	{
	  CWMIMEMultipart *aMimeMultipart;
	  int i, c;
	  
	  aMimeMultipart = (CWMIMEMultipart *)[thePart content];
	  c = [aMimeMultipart count];

	  for (i = 1; i < c; i++)
	    {
	      CWPart *aPart;
	      
	      aPart = [aMimeMultipart partAtIndex:i];
	      
	      if ([aPart isMIMEType: @"application"  subType: @"pgp-signature"])
		{
		  [self _verifyPart: [aMimeMultipart partAtIndex: 0]
			allPart: thePart
			rawSource: (NSData *)aMutableData 
			signaturePart: aPart 
			message: theMessage];
		  [aMimeMultipart removePart: aPart];
		  break;
		}
	    }
	}
      
      RELEASE(aMutableData);
    }
  


  // Cleanups
  [[NSFileManager defaultManager] removeFileAtPath: inFilename  handler: nil];      
  [[NSFileManager defaultManager] removeFileAtPath: outFilename handler: nil];
  free(s1);
  free(s2);

  RELEASE(aTask);
}




//
// GPG commands:
//
//  --batch  Use batch mode.  Never ask, do not allow  inter­
//           active commands.
//
//  --status-fd n
//           Write   special   status  strings  to  the  file
//           descriptor n.  See the file DETAILS in the docu­
//           mentation for a listing of them.
//
- (void) _verifyPart: (CWPart *) thePart 
             allPart: (CWPart *) allPart 
           rawSource: (NSData *) rawData 
       signaturePart: (CWPart *) signPart 
             message: (CWMessage *) theMessage
{	  
  NSString *aLaunchPath, *outFilename, *signFilename, *dataFilename, *aBoundary;
  NSPipe *standardInput, *standardError;
  NSMutableString *aWarningMessage;
  NSMutableData *aMutableData;
  NSMutableArray *arguments;
  NSTask *aTask;
  NSData *aData;
  BOOL pinentryLoopback;

  NSRange aRange;
  char *s1, *s2;
  
  // We generate tempory filenames
  s1 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  dataFilename = [NSString stringWithFormat: @"%s", s1];
  signFilename = [NSString stringWithFormat: @"%s.sig", s1];
  s2 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  outFilename = [NSString stringWithFormat: @"%s.out", s2];
  
  // We first get our launch path
  aLaunchPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_GPG_PATH"];

  // Check if we should enable pinentry loopback
  pinentryLoopback = [[NSUserDefaults standardUserDefaults] boolForKey: @"PGPBUNDLE_GPG_PINELOOP"];

  if (!aLaunchPath || ([aLaunchPath length] == 0))
    {
#ifdef MACOSX
      aLaunchPath = @"/usr/local/bin/gpg";
#else
      aLaunchPath = @"/usr/bin/gpg";
#endif
    }
  
  // We now verify if file exist & is executable
  if (![[NSFileManager defaultManager] isExecutableFileAtPath: aLaunchPath])
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"The file %@ does not exist or is not executable"),
                      _(@"OK"),   // default
                      NULL,       // alternate
                      NULL,
		      aLaunchPath);
      return;
    }

  // We create our task object
  aTask = [[NSTask alloc] init];
  [aTask setLaunchPath: aLaunchPath];  
  
  // We initialize our arguments
  arguments = [[NSMutableArray alloc] initWithObjects:  @"--batch", // Use batch mode.
				      @"--no-tty", 		    // Make sure that the TTY (terminal) is
				                                    // never used for any output.
				      @"--status-fd", @"2",	    // Write special status strings to the file 
				                                    // descriptor 2.
				      @"-o", outFilename,	    // Write output to file.
				      @"--verify", 
				      signFilename, 		    // signature file name
				      dataFilename, 		    // signed file name
				      nil];

  if (pinentryLoopback)
    {
      // skip passphrase requestor
      [arguments addObject: @"--pinentry-mode"];
      [arguments addObject: @"loopback" ];
    }

  // We write our signature to a temporary file
  [(NSData *)[signPart content] writeToFile: signFilename  atomically: YES];
  [[NSFileManager defaultManager] enforceMode: 0600  atPath: signFilename];

  // We create our standard input handle pipe
  standardInput = [NSPipe pipe];
  
  // We the raw source of our part / message isn't available, let's obtain it.
  if (rawData == nil)
    {
      // We replace all occurences of \r\n by \n
      aMutableData = AUTORELEASE([[NSMutableData alloc] initWithData: [theMessage rawSource]]);
      [aMutableData replaceCRLFWithLF];
      aData = aMutableData;
      aBoundary = [NSString stringWithFormat: @"--%s", [[theMessage boundary] cString]];
    }
  else
    {
      aData = rawData;
      aBoundary = [NSString stringWithFormat: @"--%s", [[allPart boundary] cString]];
    }
  
  // We get the data enclosed in our boundary. First we search for
  // a starting point.
  aRange = [aData rangeOfCString: [aBoundary cString]];
  aData = [aData subdataFromIndex: NSMaxRange(aRange)+1];
  
  // Then we search for an ending point, trimming everything
  // to that ending point.
  aRange = [aData rangeOfCString: [aBoundary cString]];	
  aRange.length = aRange.location-1;
  aRange.location = 0;
  aData = [aData subdataWithRange: aRange];
  
  // Before feeding everything to gpg, we must replace
  // all occurences of LF by CRLF.
  aMutableData = AUTORELEASE([[NSMutableData alloc] initWithData: aData]);
  aData = (NSData *)[aMutableData replaceLFWithCRLF];
  
  // We finally write our data to a file. We'll use this
  // file for verification.
  [aData writeToFile: dataFilename  atomically: YES];
  [[NSFileManager defaultManager] enforceMode: 0600  atPath: dataFilename];
  
  
  // We set the stdin / stdout
  [aTask setStandardInput: standardInput];
  
  // We set our task's standard error
  standardError = [NSPipe pipe];
  [aTask setStandardError: standardError];
  
  // We set our task's arguments
  [aTask setArguments: arguments];
  RELEASE(arguments);
  
  // We create our mutable data and string object
  aWarningMessage = [[NSMutableString alloc]
		      initWithString: _(@"Authentication failed due the following reason(s):\n")];
  aMutableData = [[NSMutableData alloc] init];
  
  // We lauch our task
  [aTask launch];
  
  // While the task is dunning, we accumulate the infoz read on stderr
  // into aMutableData.
  while ([aTask isRunning])
    {
      [aMutableData appendData: [[standardError fileHandleForReading] availableData]];
    }
  
  // We analyse the output of our GPG task to stderr. If it the authentication
  // failed, we do some cleanups.
  if (![self _analyseTaskOutput: aMutableData  message: aWarningMessage])
    {
      // We show the reason why authentication failed
      NSRunAlertPanel(_(@"Error!"),
		      aWarningMessage,
		      _(@"OK"),   // default
		      NULL,       // alternate
		      NULL);
      
      // We remove our temporary files and we free some vars
      [[NSFileManager defaultManager] removeFileAtPath: dataFilename  handler:nil];      
      [[NSFileManager defaultManager] removeFileAtPath: signFilename  handler:nil];      
      [[NSFileManager defaultManager] removeFileAtPath: outFilename  handler:nil];     
      free(s1);
      free(s2);
      
      RELEASE(aMutableData);
      RELEASE(aWarningMessage);
      RELEASE(aTask);
      
      return;
    }
  else
    {
      if ([aMutableData rangeOfCString: "GOODSIG"  options: NSCaseInsensitiveSearch].length > 0)
	{
	  [theMessage setProperty: [NSNumber numberWithInt: SIGNED]  forKey: @"CONTENT-STATUS"];
	}
    }

  
  // Cleanups
  [[NSFileManager defaultManager] removeFileAtPath: dataFilename  handler:nil];      
  [[NSFileManager defaultManager] removeFileAtPath: signFilename  handler:nil];      
  [[NSFileManager defaultManager] removeFileAtPath: outFilename  handler:nil];     
  free(s1);
  free(s2);

  RELEASE(aMutableData);
  RELEASE(aWarningMessage);  
  RELEASE(aTask);
}


//
//
// GPG commands:
//
// SIGN ONLY to ludovic@Sophos.ca: OR
// SIGN ONLY to foo@bar.com
//
// /usr/bin/gpg --batch --no-tty --status-fd 2
// --comment 'Using GnuPG with Mozilla - http://enigmail.mozdev.org'
// --always-trust --encrypt-to ludovic@Sophos.ca --clearsign -u ludovic@Sophos.ca --passphrase-fd 0
//
//
// ENCRYPT ONLY to ludovic@Sophos.ca
// 
// To encrypt, we must have the public key of -r
//
//
// /usr/bin/gpg --batch --no-tty --status-fd 2
// --comment 'Using GnuPG with Mozilla - http://enigmail.mozdev.org' 
// --always-trust --encrypt-to ludovic@Sophos.ca -a -e -u ludovic@Sophos.ca -r ludovic@Sophos.ca
//
//
// ENCRYPT ONLY to foo@bar.com
//
// /usr/bin/gpg --batch --no-tty --status-fd 2 
// --comment 'Using GnuPG with Mozilla - http://enigmail.mozdev.org' 
// --always-trust --encrypt-to ludovic@Sophos.ca -a -e -u ludovic@Sophos.ca -r foo@bar.com
//
//
//  -a, --armor
//               Create ASCII armored output.
//
//  -e, --encrypt
//               Encrypt data. This option may be  combined  with
//               --sign.
//
//
// ENCRYPT AND SIGN to ludovic@Sophos.ca
//
// /usr/bin/gpg --batch --no-tty --status-fd 2 
// --comment 'Using GnuPG with Mozilla - http://enigmail.mozdev.org'
// --always-trust --encrypt-to ludovic@Sophos.ca -a -e -s -u ludovic@Sophos.ca -r ludovic@Sophos.ca 
// --passphrase-fd 0
//
// FIXME: Should return the new message instead of modifying directly :)
//
- (CWMessage *) _encryptMessage: (CWMessage *) theMessage
		      multipart: (BOOL) aBOOL

{
  NSString *aLaunchPath, *aUserID, *inFilename, *outFilename, *aPassphrase;
  NSPipe *standardInput, *standardError;
  NSMutableString *aWarningMessage;
  NSMutableData *aMutableData;
  NSMutableArray *arguments;
  NSArray *allRecipients; 
  NSTask *aTask;
  NSMutableArray *encryptRecipients;
  BOOL pinentryLoopback = YES;

  BOOL encapsulationFlag;
  char *s1, *s2;
  int i;

  encapsulationFlag = NO;

  // We generate our filename  
  s1 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  outFilename = [NSString stringWithCString: s1];
  s2 = tempnam([GNUMailTemporaryDirectory() cString], NULL);
  inFilename = [NSString stringWithCString: s2];


  // We get our User ID (E-Mail address only). We use it for the following GPG parameters
  // (and also to obtain the GPG passphrase):
  // 
  // --encrypt-to
  // -u
  //
  if (![[NSUserDefaults standardUserDefaults] objectForKey: @"PGPBUNDLE_USE_FROM_FOR_SIGNING"] ||
      [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_USE_FROM_FOR_SIGNING"] == NSOnState)
    {
      aUserID = [[theMessage from] address];
    }
  else
    {
      aUserID = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_USER_EMAIL_ADDRESS"];
    }
  
  // We get our recipient User ID
  allRecipients = [theMessage recipients];
  encryptRecipients = [[NSMutableArray alloc] init];
  
  for (i = 0; i < [allRecipients count]; i++)
    {
      CWInternetAddress *aInternetAddress;
      
      aInternetAddress = [allRecipients objectAtIndex: i];
      
      if ([aInternetAddress type] == PantomimeToRecipient)
	{
		[encryptRecipients addObject: [aInternetAddress address]];
	}
    }
 
  
  // We first get our launch path
  aLaunchPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"PGPBUNDLE_GPG_PATH"];
  
  // Check if we should enable pinentry loopback
  pinentryLoopback = [[NSUserDefaults standardUserDefaults] boolForKey: @"PGPBUNDLE_GPG_PINELOOP"];
  
  if (!aLaunchPath || [aLaunchPath length] == 0)
    {
#ifdef MACOSX
      aLaunchPath = @"/usr/local/bin/gpg";
#else
      aLaunchPath = @"/usr/bin/gpg";
#endif
    }

  // We now verify if file exist & is executable
  if (![[NSFileManager defaultManager] isExecutableFileAtPath: aLaunchPath])
    {
      NSRunAlertPanel(_(@"Error!"),
		      _(@"The file %@ does not exist or is not executable"),
                      _(@"OK"),   // default
                      NULL,       // alternate
                      NULL,
		      aLaunchPath);
      return nil;
    }

  // We create our task object
  aTask = [[NSTask alloc] init];
  [aTask setLaunchPath: aLaunchPath];

  // Let's create our array of arguments
  arguments = [[NSMutableArray alloc] initWithObjects: @"--batch", 
				      @"--no-tty",
				      @"--status-fd",
				      @"2",
				      @"--comment",
				      @"Using the GPG bundle for GNUMail",
				      @"--always-trust", 
				      @"--encrypt-to",
				      aUserID,         // ex: ludovic@Sophos.ca
				      nil];
  
  if (pinentryLoopback)
    {
      [arguments addObject: @"--pinentry-mode"];
      [arguments addObject: @"loopback" ];
    }
  
  //
  // If we sign ONLY
  //
  if ([sign tag] == SIGNED && [encrypt tag] == NOT_ENCRYPTED)
    {
      if (aBOOL)
	{
	  [arguments addObject: @"-a"];	// ASCII armored output
	  [arguments addObject: @"-s"];	// make a signature
	  [arguments addObject: @"-b"];	// make a detached signature
	}
      else
	{
	  [arguments addObject: @"--clearsign"]; // make a clear text signature
	}
    }
  //
  // If we encrypt ONLY
  //
  else if ([sign tag] == NOT_SIGNED && [encrypt tag] == ENCRYPTED )
    {
      [arguments addObject: @"-a"];  // ASCII armored output
      [arguments addObject: @"-e"];  // encrypt
      for (i = 0; i < [encryptRecipients count]; i++) {
        [arguments addObject: @"-r"];  // recipient user-id    
		[arguments addObject: [encryptRecipients objectAtIndex: i]];
	  }
    }
  //
  // If we BOTH sign AND encrypt
  //
  else if ([sign tag] == SIGNED && [encrypt tag] == ENCRYPTED)
    {
    if (aBOOL)
      {
        encapsulationFlag = YES;
        [arguments addObject: @"-a"];  // ASCII armored output
        [arguments addObject: @"-s"];  // make a signature
        [arguments addObject: @"-b"];  // make a detached signature
      } 
    else
      {
	[arguments addObject: @"-a"];  // ASCII armored output
	[arguments addObject: @"-e"];  // encrypt
	[arguments addObject: @"-s"];  // and sign
      for (i = 0; i < [encryptRecipients count]; i++) {
        [arguments addObject: @"-r"];  // recipient user-id    
		[arguments addObject: [encryptRecipients objectAtIndex: i]];
	  }
      }
    }
  
  RELEASE(encryptRecipients);
  //
  // Last standard arguments
  //
  [arguments addObject: @"-u"];
  [arguments addObject: aUserID]; // ex: ludovic@Sophos.ca
  [arguments addObject: @"--passphrase-fd"];
  [arguments addObject: @"0"];
  [arguments addObject: @"-o"];
  [arguments addObject: outFilename];
  
  if (aBOOL)
    {
      [arguments addObject: inFilename];
    }
  
  [aTask setArguments: arguments];
  RELEASE(arguments);
  
  if (aBOOL)
    {
      // We generate our raw data of the "Part"'s part of our Message
      NSMutableData *rawSourceOfPart;
      NSData *aData;
      NSRange aRange;
      
      rawSourceOfPart = [[NSMutableData alloc] init];
      
      // We add our Content-Type: abc/def; boundary="--foo" to our message
      if ([theMessage isMIMEType: @"multipart"  subType: @"signed"] && 
	  [encrypt tag] == ENCRYPTED && 
	  [sign tag] == NOT_SIGNED)
	{
	  [rawSourceOfPart appendCFormat: @"Content-Type: multipart/signed; protocol=\"application/pgp-signature\"; micalg=pgp-sha1;\n\tboundary=\"%s\"\n\n",
			   [[theMessage boundary] cString]];
	  
	  // We append our message content
	  aData = [theMessage dataValue];
	  aRange = [aData rangeOfCString: "\n\n"];
	  aData = [aData subdataFromIndex: (aRange.location + 2)];
	  
	  [rawSourceOfPart appendData: aData];
	  
	  // We write our mail content to a temporary file
	  [[rawSourceOfPart replaceLFWithCRLF] writeToFile: inFilename  atomically: YES];
	  [[NSFileManager defaultManager] enforceMode: 0600  atPath: inFilename];
	}
      else
	{
	  [rawSourceOfPart appendCFormat: @"Content-Type: %@;\n", [theMessage contentType]];
	  [rawSourceOfPart appendCFormat: @"\tboundary=\""];
	  [rawSourceOfPart appendData: [theMessage boundary]];
	  [rawSourceOfPart appendCFormat: @"\"\n\n"];
	  
	  // We append our message content
	  aData = [theMessage dataValue];
	  aRange = [aData rangeOfCString: "\n\n"];
	  aData = [aData subdataFromIndex: (aRange.location + 2)];
	  
	  [rawSourceOfPart appendData: aData];
	  
	  // We write our mail content to a temporary file
	  if ([sign tag] == SIGNED)
	    {
	      [[rawSourceOfPart replaceLFWithCRLF] writeToFile: inFilename  atomically: YES];
	      [[NSFileManager defaultManager] enforceMode: 0600  atPath: inFilename];
	    }
	  else
	    {
	      [rawSourceOfPart writeToFile: inFilename  atomically: YES];
	      [[NSFileManager defaultManager] enforceMode: 0600  atPath: inFilename];
	    }
	}
      RELEASE(rawSourceOfPart);
    }
  
  // We create our standard input handle pipe and we set the stdin
  standardInput = [NSPipe pipe];
  [aTask setStandardInput: standardInput];
  
  // We set our task's standard error
  standardError = [NSPipe pipe];
  [aTask setStandardError: standardError];
  
  // We obtain our passphrase 
  aPassphrase = [self _passphraseForID: aUserID];    // ex: ludovic@Sophos.ca

  // We lauch our task
  [aTask launch];

  // We write everything to the pipe
  [[standardInput fileHandleForWriting] writeData:
					  [aPassphrase dataUsingEncoding:
							 NSASCIIStringEncoding]];
  // We 'flush' the passphrase by writing a \n
  [[standardInput fileHandleForWriting] writeData: [NSData dataWithBytes: "\n"  length: 1]];

  // We write our part content
  if (!aBOOL)
    {
      NSData *aData;
      NSRange aRange;
      int encoding;

      encoding = [NSString encodingForCharset: 
			     [[theMessage charset] dataUsingEncoding: NSASCIIStringEncoding]];
      if (encoding == -1)
	{
	  encoding = NSASCIIStringEncoding;
	}
      
      // We set our message content
      aData = [theMessage dataValue];
      aRange = [aData rangeOfCString: "\n\n"];
      aData = [aData subdataFromIndex: (aRange.location + 2)];
      
      if ([theMessage contentTransferEncoding] == PantomimeEncodingQuotedPrintable)
	{
	  aData = [aData decodeQuotedPrintableInHeader: NO];
	  
	  if (encoding == NSISO2022JPStringEncoding)
	    {
	      // ISO-2022-JP message does not need quoted-printable encoding, because ISO-2022-JP is 7bit code
	      [theMessage setContentTransferEncoding: PantomimeEncodingNone];
	    }
	  else if (encoding == NSUTF8StringEncoding)
	    {
	      // If the encoding of Japanese messages is UTF-8, base64 is better than quoted-printable
	      [theMessage setContentTransferEncoding: PantomimeEncodingBase64];
	    }
	}
      else if ([theMessage contentTransferEncoding] == PantomimeEncodingBase64)
	{
	  aData = [aData decodeBase64];
	}
      
      // We write the data to our pipe
      [[standardInput fileHandleForWriting] writeData: aData];
    }


  [[standardInput fileHandleForWriting] closeFile];
  
  // We create our mutable data and string object
  aWarningMessage = [[NSMutableString alloc]
		      initWithString: _(@"Encryption failed due the following reason(s):\n")];
  aMutableData = [[NSMutableData alloc] init];
  
  
  // While the task is dunning, we accumulate the infoz read on stderr
  // into aMutableData.
  while ([aTask isRunning])
    {
      [aMutableData appendData: [[standardError fileHandleForReading] availableData]];
    }
  
  // We analyse the output of our GPG task to stderr. If it the encryption
  // failed, we do some cleanups.
  if (![self _analyseTaskOutput: aMutableData  message: aWarningMessage] ||
      [aTask terminationStatus] > 0)
    {
      // We show the reason why decryption failed
      NSRunAlertPanel(_(@"Error!"),
		      aWarningMessage,
                      _(@"OK"),   // default
                      NULL,       // alternate
                      NULL);
      
      
      // FIXME: move to the _analyseTaskOutput:: method
      // We remove the passphrase for this ID
      [passphraseCache removeObjectForKey: aUserID];

      // We remove our temporary file and we free some vars
      [[NSFileManager defaultManager] removeFileAtPath: outFilename
				      handler: nil];

      if (aBOOL)
	{
	  [[NSFileManager defaultManager] removeFileAtPath: inFilename  handler: nil];
	}
      
      free(s2);
      free(s1);
      RELEASE(aWarningMessage);
      RELEASE(aMutableData);
      RELEASE(aTask);

      return nil;
    }
  
  RELEASE(aWarningMessage);
  RELEASE(aMutableData);
  
  //
  // Encryption or signing (or both!) has completed. We now replace the
  // actual content of the message with the new one.
  //
  if (!aBOOL) 
    {
      [theMessage setContent: [NSData dataWithContentsOfFile: outFilename]];
    }
  else if (([sign tag] == SIGNED && [encrypt tag] == NOT_ENCRYPTED) || encapsulationFlag)
    {
      NSMutableData *rawSource, *aMutableData;
      NSString *aString, *aBoundary;
      NSData  *aBoundaryData, *aData;
      NSRange aRange;
      
      // We generate a new boundary
      aBoundaryData = [CWMIMEUtility globallyUniqueBoundary];
      aBoundary = [NSString stringWithFormat: @"\n--%s", [aBoundaryData cString]];
      
      aString = [NSString stringWithFormat: @"Content-type: multipart/signed; protocol=\"application/pgp-signature\"; micalg=pgp-sha1;\n\tboundary=\"%s\"\n", [aBoundaryData cString]];
      aString = [NSString stringWithFormat: @"%@%@\nContent-Type: multipart/mixed; boundary=\"%s\"\n", 
			  aString, aBoundary, [[theMessage boundary] cString]];
      
      rawSource = [[NSMutableData alloc] init];
      [rawSource appendCFormat: @"%@\n", aString];

      // We replace all occurences of \r\n by \n
      aMutableData = [[NSMutableData alloc] initWithData: [NSData dataWithContentsOfFile: inFilename]];
      [aMutableData replaceCRLFWithLF];
      aData = aMutableData;
      aRange = [aData rangeOfCString: "\n\n"];
      aData = [aData subdataFromIndex: (aRange.location + 2)];
      [rawSource appendData: aData];
      RELEASE(aMutableData);

      // We set our signature
      [rawSource appendCFormat: @"%@\ncontent-type: application/pgp-signature\n\n%@%@--\n",
                    aBoundary, [NSString stringWithContentsOfFile: outFilename], aBoundary];

      [theMessage setBoundary: aBoundaryData];
      [theMessage setContentType: @"multipart/signed"];
      [theMessage setProtocol: [@"application/pgp-signature"
                                    dataUsingEncoding: NSASCIIStringEncoding]];
      [theMessage setContentTransferEncoding: PantomimeEncodingNone];
      [CWMIMEUtility setContentFromRawSource: rawSource  inPart: (CWPart *)theMessage];
      RELEASE(rawSource);
      
      if (encapsulationFlag)
	{
	  [sign setTag: NOT_SIGNED];
	  [self _encryptMessage: theMessage  multipart: YES];
	}
    }
  else
    {
      CWMIMEMultipart *aMimeMultipart;
      NSData *aBoundary;
      NSString *aString;
      CWPart *aPart;
      
      // We create our new multipart object
      aMimeMultipart = [[CWMIMEMultipart alloc] init];
      
      //
      // We add our extra part (Version: 1)
      //
      aPart = [[CWPart alloc] init];
      [aPart setContentTransferEncoding: PantomimeEncodingNone];
      [aPart setContentType: @"application/pgp-encrypted"];
      [aPart setContent: [@"Version: 1" dataUsingEncoding: NSASCIIStringEncoding]];
      [aPart setSize: 10];
      [aMimeMultipart addPart: aPart];
      RELEASE(aPart);
      
      //
      // We add our encrypted part
      //
      // This is safe since our output is ASCII armored when encrypted
      aString = [NSString stringWithContentsOfFile: outFilename];
      aString = [aString stringByAppendingString: @"\n"];
      
      aPart = [[CWPart alloc] init];
      [aPart setContentTransferEncoding: PantomimeEncodingNone];
      [aPart setContentType: @"application/octet-stream"];
      [aPart setContent: [aString dataUsingEncoding: NSASCIIStringEncoding]];
      [aPart setSize: [aString length]];
      [aMimeMultipart addPart: aPart];
      RELEASE(aPart);
      
      // We generate a new boundary
      aBoundary = [CWMIMEUtility globallyUniqueBoundary];
      
      // We set the new boundary, the new Content-Type and the Content-Transfer-Encoding to our message
      [theMessage setBoundary: aBoundary];
      [theMessage setContentType: @"multipart/encrypted"];
      [theMessage setProtocol: [@"application/pgp-encrypted"
				 dataUsingEncoding: NSASCIIStringEncoding]];
      [theMessage setContentTransferEncoding: PantomimeEncodingNone];
      
      // We finally set the new multipart content
      [theMessage setContent: aMimeMultipart];
      RELEASE(aMimeMultipart);
    }
  
  // Cleanups
  [[NSFileManager defaultManager] removeFileAtPath: outFilename  handler: nil];
  
  if (aBOOL)
    {
      [[NSFileManager defaultManager] removeFileAtPath: inFilename  handler: nil];
    }

  free(s2);
  free(s1);
  
  RELEASE(aTask);

  return theMessage;
}


//
//
//
- (void) _messageFetchCompleted: (NSNotification *) theNotification
{
  NSTextView *aTextView;
  CWMessage *aMessage;
  
  aMessage = [[theNotification userInfo] objectForKey: @"Message"];
  aTextView = [aMessage propertyForKey: @"NSTextView"];
  RETAIN(aTextView);

  // We flush the previous properties
  [aMessage setProperty: nil  forKey: @"NSTextView"];
  [aMessage setProperty: nil  forKey: @"Loading"];

  if (aTextView && [aTextView window] && [[aTextView window] isVisible])
    {
      id aController;

      aController = [aTextView delegate];

      if ([aController selectedMessage] == aMessage)
	{
	  // We decode our message for real now since we have our raw source.
	  [self messageWillBeDisplayed: aMessage  inView: aTextView];

	  // We display it!
	  [Utilities showMessage: aMessage  target: aTextView  showAllHeaders: NO]; 
	}
    }

  RELEASE(aTextView);
}

//
// The ID is, for example: ludovic@Sophos.ca
//
- (NSString *) _passphraseForID: (NSString *) theID
{
  Passphrase *aPassphrase;
  
  // We first verify in our cache
  aPassphrase = [passphraseCache objectForKey: theID];
  
  // If we must prompt for the password
  if (!aPassphrase)
    {
      PasswordPanelController *theController; 
      int result;
      
      theController = [[PasswordPanelController alloc] initWithWindowNibName: @"PasswordPanel"];
      [[theController window] setTitle: [NSString stringWithFormat: _(@"Passphrase for %@"),
						  theID]];
      
      result = [NSApp runModalForWindow: [theController window]];
      
      // If the user has entered a password...
      if (result == NSRunStoppedResponse)
	{
	  // Let's cache this password...
	  aPassphrase = [[Passphrase alloc] initWithValue: [theController password]];
	  [passphraseCache setObject: aPassphrase
			   forKey: theID];
	  RELEASE(aPassphrase);
	}
      else
	{
	  aPassphrase = nil;
	}
      
      RELEASE(theController);
    }
  
  return [aPassphrase value];
}


//
//
//
- (void) _tick
{
  NSEnumerator *theEnumerator;
  NSCalendarDate *date;
  NSString *aKey;

  NSInteger minutes, value;

  theEnumerator = [passphraseCache keyEnumerator];

  value = [[NSUserDefaults standardUserDefaults] integerForKey: @"PGPBUNDLE_PASSPHRASE_EXPIRY_VALUE"];
  date = (NSCalendarDate *)[NSCalendarDate date];

  while ((aKey = [theEnumerator nextObject]))
    {
      Passphrase *aPassphrase;

      aPassphrase = [passphraseCache objectForKey: aKey];

      [date years: NULL
	    months: NULL
	    days: NULL
	    hours: NULL
	    minutes: &minutes
	    seconds: NULL
	    sinceDate: (NSCalendarDate *)[aPassphrase date]];

      // We must remove the passphrase from the cache
      if (minutes >= value)
	{
	  [passphraseCache removeObjectForKey: aKey];
	}
    }
}
@end

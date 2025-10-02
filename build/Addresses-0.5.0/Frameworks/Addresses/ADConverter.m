// ADConverter.m (this is -*- ObjC -*-)
// 
// Author: Björn Giesler <giesler@ira.uka.de>
//         Riccardo Mottola <rm@gnu.org>

// Address Book Framework for GNUstep
// 


#import "ADConverter.h"
#import "ADPListConverter.h"
#import "ADVCFConverter.h"

ADConverterManager *_manager = nil;

@implementation ADConverterManager
+ (ADConverterManager*) sharedManager
{
  if(!_manager)
    _manager = [[self alloc] init];
  return _manager;
}

- (instancetype)init
{
  self = [super init];
  if (self)
    {
      _icClasses = [[NSMutableDictionary alloc] initWithCapacity: 1];
      _ocClasses = [[NSMutableDictionary alloc] initWithCapacity: 1];

      // couple of standard converters
  
      [self registerInputConverterClass: [ADPListConverter class]
				forType: @"mfaddr"];
  
      [self registerInputConverterClass: [ADVCFConverter class]
				forType: @"vcf"];
      [self registerOutputConverterClass: [ADVCFConverter class]
				 forType: @"vcf"];
    }

  return self;
}

- (BOOL) registerInputConverterClass: (Class) c
			     forType: (NSString*) type
{
  type = [type lowercaseString];
  if([[_icClasses allKeys] containsObject: type])
    return NO;

  [_icClasses setObject: c forKey: type];
  return YES;
}

- (BOOL) registerOutputConverterClass: (Class) c
			      forType: (NSString*) type
{
  type = [type lowercaseString];
  if([[_ocClasses allKeys] containsObject: type])
    return NO;

  [_ocClasses setObject: c forKey: type];
  return YES;
}

- (id<ADInputConverting>) inputConverterForType: (NSString*) type
{
  Class c;

  c = [_icClasses objectForKey: type];
  if(!c) return nil;
  return [[[c alloc] initForInput] autorelease];
}

- (id<ADOutputConverting>) outputConverterForType: (NSString*) type
{
  Class c;

  c = [_ocClasses objectForKey: type];
  if(!c) return nil;
  return [[[c alloc] initForOutput] autorelease];
}

- (id<ADInputConverting>) inputConverterWithFile: (NSString*) filename
{
  id<ADInputConverting> obj;
  Class c;
  NSData *data;
  NSString *string;

  c = [_icClasses objectForKey: [[filename pathExtension]
				  lowercaseString]];
  if(!c)
    return nil;

  obj = [[[c alloc] initForInput] autorelease];

  data = [NSData dataWithContentsOfFile: filename];
  if (!data || [data length] < 5)
    {
      NSLog(@"Error while reading file %@", filename);
      return nil;
    }

  /* UTF-8 is standard, so it is our first attempt */
  string = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
  if (!string)
    {
      const unichar *data_unichar = (const unichar *)(void *) [data bytes];

      NSLog(@"File in is notNSUTF8StringEncoding. vCARD RFC 6350 specifies UTF-8 as only valid encoding");
      if ((data_unichar[0] == 0xFEFF) || (data_unichar[0] == 0xFFFE))
	{
	  NSLog(@"found an UTF-16 BOM");

	  string = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
	}
    }

  if (!string)
    {
      NSLog(@"Attempting NSISOLatin1StringEncoding");
      string = [[NSString alloc] initWithData:data encoding: NSISOLatin1StringEncoding];
    }

  if (!string)
    {
      NSLog(@"Attempting NSISOLatin2StringEncoding");
	    
      string = [[NSString alloc] initWithData:data encoding: NSISOLatin2StringEncoding];
    }

  if (!string)
    {
      NSLog(@"No encoding found for file %@, aborting.", filename);
      return nil;
    }
 
  if (![obj useString: AUTORELEASE(string)])
    return nil;

  return obj;
}

- (NSArray*) inputConvertableFileTypes
{
  return [_icClasses allKeys];
}
  
- (NSArray*) outputConvertableFileTypes
{
  return [_ocClasses allKeys];
}

@end

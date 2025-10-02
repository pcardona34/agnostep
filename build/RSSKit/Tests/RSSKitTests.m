#import "RSSKitTests.h"
#import "GNUstep.h"

@implementation RSSFeed (Resources)
+(id)feedWithResource: (NSString*)aResourceName
{
  return AUTORELEASE([[self alloc] initWithResource: aResourceName]);
}
-(id)initWithResource: (NSString*)aResourceName
{
  NSBundle* testsBundle = [NSBundle bundleForClass: [RSSKitTests class]];
  NSString* res = [testsBundle pathForResource: aResourceName ofType: @"xml"];
  
  NSURL* url = [NSURL fileURLWithPath: res];
  
  return [self initWithURL: url];
}
@end



@implementation RSSKitTests

- (void) testNothing
{
//  UKFail();
}

@end


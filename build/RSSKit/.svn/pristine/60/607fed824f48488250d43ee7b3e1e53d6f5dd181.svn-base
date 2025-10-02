#import "RSSTests.h"
#import "GNUstep.h"

@implementation RSSTests

-(void)testChannelTitle
{
  FETCH(@"channel_title");
  UKStringsEqual([feed description], @"Example feed");
}

-(void)testChannelTitleApos
{
  FETCH(@"channel_title");
  UKStringsEqual([feed description], @"Mark's title");
}

-(void)testChannelTitleGt
{
  FETCH(@"channel_title");
  UKStringsEqual([feed description], @"2 > 1");
}

-(void)testChannelTitleLt
{
  FETCH(@"channel_title");
  UKStringsEqual([feed description], @"1 < 2");
}

@end

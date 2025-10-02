/** -*-objc-*-
 * RSSKit Test Suite by Guenther Noack
 *
 */

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import <RSSKit/RSSKit.h>

#import "RSSKitTests.h"

@interface RDFTests : NSObject <UKTest> {
  
}

-(void)testChannelDesc;
-(void)testChannelLink;
-(void)testChannelTitle;
-(void)testItemDesc;
-(void)testItemLink;
-(void)testItemRDFAbout;
-(void)testItemTitle;

/*
-(void)testRSS090ChannelTitle;
-(void)testRSS090ItemTitle;
-(void)testRSSV10;
-(void)testRSSV10NotDefaultNS;

*/

@end


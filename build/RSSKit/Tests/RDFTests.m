#import "RDFTests.h"
#import "GNUstep.h"

/**
 * Runs simple tests for RDF (RSS 1.0) files.
 */
@implementation RDFTests

-(void)testChannelDesc
{
  FETCH(@"rdf_channel_description");
  
  // FIXME: [feed description] is not a way to get the *description* but
  // to get the *title* of the feed!
  UKStringsEqual([feed description], @"Example description");
}

-(void)testChannelLink
{
  FETCH(@"rdf_channel_link");
  UKStringsEqual([[feed feedURL] description], @"Example feed");
}

-(void)testChannelTitle
{
  FETCH(@"rdf_channel_title");
  UKStringsEqual([feed description], @"Example feed");
}

-(void)testItemDesc
  {
    FETCH(@"rdf_item_description");
    UKTrue([feed count] > 0);
    
    RSSArticle* art = [feed articleAtIndex: 0];
    UKNotNil(art);
    
    UKStringsEqual([art description], @"Example description");
  }

-(void)testItemLink
  {
    FETCH(@"rdf_item_link");
    UKTrue([feed count] > 0);
    
    RSSArticle* art = [feed articleAtIndex: 0];
    UKNotNil(art);
    
    UKStringsEqual(@"http://example.com/1", [art url]);
  }

-(void)testItemRDFAbout
  {
    FETCH(@"rdf_item_rdf_about");
    UKTrue([feed count] > 0);
    
    RSSArticle* art = [feed articleAtIndex: 0];
    UKNotNil(art);
    
    // XXX: The semantics of rdf:about? Can we use this as URL?
    UKStringsEqual(@"http://example.org/1", [art url]);
  }

-(void)testItemTitle
  {
    FETCH(@"rdf_item_title");
    UKTrue([feed count] > 0);
    
    RSSArticle* art = [feed articleAtIndex: 0];
    UKNotNil(art);
    
    UKStringsEqual([art headline], @"Example title");
  }

/*

-(void)testRSS090ChannelTitle
  {
  }

-(void)testRSS090ItemTitle
  {
  }

-(void)testRSSV10
  {
  }

-(void)testRSSV10NotDefaultNS
  {
  }

*/

@end


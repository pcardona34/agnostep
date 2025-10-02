#include <Foundation/NSString.h>
@interface NSFramework_Functions
+ (NSString *)frameworkEnv;
+ (NSString *)frameworkPath;
+ (NSString *)frameworkVersion;
+ (NSString **)frameworkClasses;
@end
@implementation NSFramework_Functions
+ (NSString *)frameworkEnv { return nil; }
+ (NSString *)frameworkPath { return @"/usr/GNUstep/Local/Library/Frameworks"; }
+ (NSString *)frameworkVersion { return @"0"; }
static NSString *allClasses[] = {@"FSAbsFunction", @"FSMaxFunction", @"FSSqrtFunction", @"FSCellnameFunction", @"FSIsEmptyFunction", @"FSMinFunction", @"FSStringFunction", @"FSCorrelFunction", @"FSPIFunction", @"FSAvgFunction", @"FSCountFunction", @"FSGroupsumFunction", @"FSStddevFunction", @"FSSumFunction", @"FSVarFunction", @"FSAcosFunction", @"FSCosFunction", @"FSCoshFunction", @"FSProdFunction", @"FSAtanFunction", @"FSTanFunction", @"FSTanhFunction", @"FSCtermFunction", @"FSFvFunction", @"FSNpvFunction", @"FSPaymentFunction", @"FSRateFunction", @"FSRandFunction", @"FSTodayFunction", @"FSIfFunction", @"FSSignFunction", @"FSLnFunction", @"FSLogFunction", @"FSAsinFunction", @"FSSinFunction", @"FSSinhFunction", NULL};
+ (NSString **)frameworkClasses { return allClasses; }
@end

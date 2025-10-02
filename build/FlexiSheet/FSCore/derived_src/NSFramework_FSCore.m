#include <Foundation/NSString.h>
@interface NSFramework_FSCore
+ (NSString *)frameworkEnv;
+ (NSString *)frameworkPath;
+ (NSString *)frameworkVersion;
+ (NSString **)frameworkClasses;
@end
@implementation NSFramework_FSCore
+ (NSString *)frameworkEnv { return nil; }
+ (NSString *)frameworkPath { return @"/usr/GNUstep/Local/Library/Frameworks"; }
+ (NSString *)frameworkVersion { return @"0"; }
static NSString *allClasses[] = {@"FSConstant", @"FSExpression", @"FSExpressionError", @"FSExpressionNegator", @"FSExpressionParenthesis", @"FSFormula", @"FSFormulaDefinition", @"FSFormulaSelection", @"FSFormulaSpace", @"FSFunction", @"FSSimpleFunction", @"FSGlobalHeader", @"FSHashMap", @"FSHeader", @"FSKey", @"FSKeyGroup", @"FSKeyRange", @"FSKeySet", @"FSLog", @"FSObject", @"FSOperator", @"FSSelection", @"FSTable", @"FSUnit", @"FSValue", @"FSVariable", NULL};
+ (NSString **)frameworkClasses { return allClasses; }
@end

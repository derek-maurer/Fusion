#import "ArrayValue.h"

@implementation NSMutableArray (ArrayValue)

-(BOOL)containsValue:(NSString *)object atIndex:(int *)index{
       int count = self.count;
       for (int i=0; i<count; i++) {
           if ([[self objectAtIndex:i] isEqualToString:object]) {
               if (*index) *index = i;
               return YES;
           }
       }
       return NO;
}

@end
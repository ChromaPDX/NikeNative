#import "FakeFriends.h"

@implementation FakeFriends

+(NSArray*)getNamesForText:(int)numNames{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
   // NSMutableArray *listOfNames = [[NSArray arrayWithObjects:
   //                                 @"ERIC",
   //                                 @"MARCUS",
   //                                 @"MIKE",
   //                                 @"VV",
   //                                 @"LEIF",
   //                                 NULL] mutableCopy];
    
    NSMutableArray *listOfNames = [[NSArray arrayWithObjects:
                                    @"MARTINA Z",
                                    @"RICKY E",
                                    @"JESSE S",
                                    @"HAYDEN W",
                                    @"DREW F",
                                    @"ERIC K",
                                    @"MARCUS E",
                                    @"MIKE M",
                                    @"VERONICA V",
                                    @"LEIF S",
                                    NULL] mutableCopy];
    
    for(int i = 0; i < numNames; i++){
        int randVal = arc4random()%[listOfNames count];
        [retArray addObject:[listOfNames objectAtIndex:randVal]];
        [listOfNames removeObjectAtIndex:randVal];
    }
    return retArray;
}

@end

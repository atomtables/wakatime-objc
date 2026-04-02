//
//  main.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>
#import "WTLogger.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        [[WTLogger shared] log:@"Hello, World!"];
        [[WTLogger shared] warn:@"Something bad's about to happen to me"];
        [[WTLogger shared] error:@"I was right."];
    }
    return EXIT_SUCCESS;
}

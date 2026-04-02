//
//  main.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>
#import "WTLogger.h"
#import "WTUtils.h"
#import "WTConfigParser.h"

typedef NS_ENUM(NSInteger, WTExitCode) {
    // normal (heartbeat was sent)
    WTExitCodeSuccess = 0,
    // failed (extreme failure)
    WTExitCodeFailure = 1,
    // offline, heartbeat is queued
    WTExitCodeHeartbeatQueued = 102,
    // api key failed to auth
    WTExitCodeBadAPIKey = 103,
    // api failed for some reason logged
    WTExitCodeAPIError = 104,
    // was not able to read config
    WTExitCodeBadConfig = 112
};

int main(int argc, const char * argv[]) {
    [[WTLogger shared] configureLoggerWithFilePath:@"~/.wakatime/log.txt" withStdout:YES withDebug:true];
    
    WTLog(@"Hello World!");
    WTWarn(@"HelloWorld");
    WTError(@"hellworld");
    
    WTConfigParser* parser = [[WTConfigParser alloc] initWithPath:[NSString stringWithFormat:@"%@/.wakatime.cfg", [WTUtils wakatimeHomeDirectory]] withError:nil];
    
    NSLog(@"%@ %@ %ld", [parser readStringWithKey:WTConfigKeyApiKey], [parser readStringWithKey:WTConfigKeyApiUrl], (long)[parser readIntegerWithKey:WTConfigKeyHeartbeatRateLimitSeconds defaultValue:0]);
    
    return EXIT_SUCCESS;
}

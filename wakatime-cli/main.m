//
//  main.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>
#import "WTLogger.h"

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
    
    return EXIT_SUCCESS;
}

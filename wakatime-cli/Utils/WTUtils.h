//
//  WTUtils.h
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 2/4/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTUtils : NSObject

+ (NSString*)wakatimeHomeDirectory;
+ (NSString*)wakatimeResourcesDirectory;

+ (bool)runWithArgv:(NSArray<NSString*>*)argv
          andOutput:(NSString*_Nonnull*_Nonnull)output
           andError:(NSError**)error;

+ (double)currentTimestamp;

@end

NS_ASSUME_NONNULL_END

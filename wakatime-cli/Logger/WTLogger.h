//
//  WTLogger.h
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTLogger : NSObject

+(instancetype)shared;
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

-(void)log:(NSString*)message;
-(void)warn:(NSString*)message;
-(void)error:(NSString*)message;

@end

NS_ASSUME_NONNULL_END

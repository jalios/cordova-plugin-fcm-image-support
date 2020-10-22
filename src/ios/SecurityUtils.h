//
//  SecurityUtils.h
//  notificationserviceextension
//
//  Created by skriaa on 08/10/2020.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecurityUtils : NSObject
+ (NSString *)decrypt:(NSString *)plainText error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END

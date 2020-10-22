//
//  SecurityUtils.m
//  notificationserviceextension
//
//  Created by skriaa on 08/10/2020.
//

// source https://github.com/juliancorrea/aes-crypto-android-and-ios
#import <Foundation/Foundation.h>
#import "SecurityUtils.h"

@implementation SecurityUtils
+ (NSString *)decrypt:(NSString *)encryptedBase64String error:(NSError **)error {
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:encryptedBase64String options:0];
    NSMutableData *result = [SecurityUtils doAES:dataToDecrypt context: kCCDecrypt error:error];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    
}

+ (NSMutableData *)doAES:(NSData *)dataIn context:(CCOperation)kCCEncrypt_or_kCCDecrypt error:(NSError **)error {
    
    NSUserDefaults *appGroupUserDefaults;
    appGroupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.jalios.jmobile.shareextension"];
    
    NSString *EncryptionKey = [appGroupUserDefaults stringForKey:@"key"];
    EncryptionKey = [EncryptionKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"key: %@", EncryptionKey);
    NSString *algo = [appGroupUserDefaults stringForKey:@"algo"];
    algo = [algo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"algo: %@", algo);
    NSString *transformation = [appGroupUserDefaults stringForKey:@"transformation"];
    transformation = [transformation stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"transformation: %@", transformation);
    
    NSString *mode = [transformation componentsSeparatedByString:@"/"][1];
    NSLog(@"mode: %@", mode);
    
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
    NSData *key =[EncryptionKey dataUsingEncoding:NSUTF8StringEncoding];
    
    if([mode isEqual:@"ECB"]){
        NSLog(@"Decrypt with ECB mode");
        ccStatus = CCCrypt( kCCEncrypt_or_kCCDecrypt,
                           kCCAlgorithmAES,
                           kCCOptionECBMode,
                           key.bytes,
                           key.length,
                           nil,
                           dataIn.bytes,
                           dataIn.length,
                           dataOut.mutableBytes,
                           dataOut.length,
                           &cryptBytes);
    } else {
        NSLog(@"Decrypt with CBC mode");
        ccStatus = CCCrypt( kCCEncrypt_or_kCCDecrypt,
                           kCCAlgorithmAES,
                           kCCOptionPKCS7Padding,
                           key.bytes,
                           key.length,
                           nil,
                           dataIn.bytes,
                           dataIn.length,
                           dataOut.mutableBytes,
                           dataOut.length,
                           &cryptBytes);
    }
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError"
                                         code:ccStatus
                                     userInfo:nil];
        }
        dataOut = nil;
    }
    
    return dataOut;
}


@end

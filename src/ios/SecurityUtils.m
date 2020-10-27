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
+ (NSString *)decrypt:(NSString *)encryptedBase64String key:(NSString *)key algo:(NSString *)algo transformation:(NSString *)transformation error:(NSError **)error {
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:encryptedBase64String options:0];
    NSMutableData *result = [SecurityUtils doAES:dataToDecrypt context: kCCDecrypt key:key algo:algo transformation:transformation error:error];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    
}

+ (NSMutableData *)doAES:(NSData *)dataIn context:(CCOperation)kCCEncrypt_or_kCCDecrypt key:(NSString *)key algo:(NSString *)algo transformation:(NSString *)transformation error:(NSError **)error {
    
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
    NSData *EncryptionKey =[key dataUsingEncoding:NSUTF8StringEncoding];

    NSString *mode = [transformation componentsSeparatedByString:@"/"][1];
    NSLog(@"mode: %@", mode);
    
    if([mode isEqual:@"ECB"]){
        NSLog(@"Decrypt with ECB mode");
        ccStatus = CCCrypt( kCCEncrypt_or_kCCDecrypt,
                           kCCAlgorithmAES,
                           kCCOptionECBMode,
                           EncryptionKey.bytes,
                           EncryptionKey.length,
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
                           EncryptionKey.bytes,
                           EncryptionKey.length,
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

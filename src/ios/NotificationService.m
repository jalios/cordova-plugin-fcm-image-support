//
//  NotificationService.m
//  notificationserviceextension
//
//  Created by skriaa on 03/11/2020.
//

@import Firebase;
#import "NotificationService.h"
#import "SecurityUtils.h"
//#import "ShareViewController.h"

@interface NotificationService () <NSURLSessionDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSString *body = self.bestAttemptContent.body;
    NSLog(@"body: %@", body);
    NSString *title = self.bestAttemptContent.title;
    NSLog(@"title: %@", title);
    NSString *secure = self.bestAttemptContent.userInfo[@"secure"];
    NSLog(@"secure: %@", secure);
    NSError *error;
    
    if([secure isEqual:@"true"]){
        NSLog(@"secure is equal to true");
        
        NSUserDefaults *appGroupUserDefaults;
        appGroupUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.jalios.jmobile.shareextension"];
        
        NSString *EncryptionMetaData = [appGroupUserDefaults stringForKey:@"encryptionMetaData"];
        
        NSData *jsonData = [EncryptionMetaData dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        
        NSString *EncryptionKey =[s objectForKey:@"key"];
        NSString *algo = [s objectForKey:@"algo"];
        NSString *transformation = [s objectForKey:@"transformation"];

        NSLog(@"key: %@", EncryptionKey);
        NSLog(@"algo: %@", algo);
        NSLog(@"transformation: %@", transformation);
        
        if((EncryptionKey != nil) && (algo != nil) && (transformation != nil)){
            // Modify the notification content here if data is not null
            if(title != nil){
                NSLog(@"title is not nil: %@", title);
                NSString *decryptedTitle = [SecurityUtils decrypt:title key:EncryptionKey algo:algo transformation:transformation error:&error];
                self.bestAttemptContent.title = decryptedTitle;
            }
            if(body != nil){
                NSLog(@"body is not nil: %@", body);
                NSString *decryptedMessage = [SecurityUtils decrypt:body key:EncryptionKey algo:algo transformation:transformation error:&error];
                self.bestAttemptContent.body = decryptedMessage;
            }
        }
    }
    
    [[FIRMessaging extensionHelper] populateNotificationContent:self.bestAttemptContent
                                             withContentHandler:contentHandler];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
}

@end

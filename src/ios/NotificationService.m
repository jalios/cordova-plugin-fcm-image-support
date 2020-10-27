//
//  NotificationService.m
//  notificationserviceextension
//
//  Created by skriaa on 29/07/2020.
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
        
        NSString *EncryptionKey = [appGroupUserDefaults stringForKey:@"key"];
        EncryptionKey = [EncryptionKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSLog(@"key: %@", EncryptionKey);
        
        NSString *algo = [appGroupUserDefaults stringForKey:@"algo"];
        algo = [algo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSLog(@"algo: %@", algo);
        
        NSString *transformation = [appGroupUserDefaults stringForKey:@"transformation"];
        transformation = [transformation stringByReplacingOccurrencesOfString:@"\"" withString:@""];
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

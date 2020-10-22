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
        // Modify the notification content here if data is not null
        if(title != nil){
            NSLog(@"title is not nil: %@", title);
            NSString *decryptedTitle = [SecurityUtils decrypt:title error:&error];
            self.bestAttemptContent.title = decryptedTitle;
        }
        if(body != nil){
            NSLog(@"body is not nil: %@", body);
            NSString *decryptedMessage = [SecurityUtils decrypt:body error:&error];
            self.bestAttemptContent.body = decryptedMessage;
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

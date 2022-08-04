//
//  SmsShare.m
//  RNShare
//
//  Created by Diseño Uno BBCL on 23-07-16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "SmsShare.h"
#import "Utils.h"


@implementation SmsShare


- (void)shareSingle:(NSDictionary *)options
    failureCallback:(RCTResponseErrorBlock)failureCallback
    successCallback:(RCTResponseSenderBlock)successCallback {

    NSLog(@"Try open view");

    if ([options objectForKey:@"message"] && [options objectForKey:@"message"] != [NSNull null]) {

        NSString *subject = @"";
        NSString *message = @"";
        
        if (![MFMessageComposeViewController canSendText]) {
            NSLog(@"Sms services are not available.");
            NSString *errorMessage = @"Sms services are not available.";
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
            NSError *error = [NSError errorWithDomain:@"com.rnshare" code:1 userInfo:userInfo];
            failureCallback(error);
           return;
        }
        
        MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
        
        mc.messageComposeDelegate = self;

        if ([options objectForKey:@"subject"] && [options objectForKey:@"subject"] != [NSNull null]) {
            subject = [RCTConvert NSString:options[@"subject"]];
        }

        message = [RCTConvert NSString:options[@"message"]];
        
        [mc setSubject:subject];
        [mc setBody:message];
        
        if ([options objectForKey:@"url"] && [options objectForKey:@"url"] != [NSNull null]) {
            
            NSURL *URL = [RCTConvert NSURL:options[@"url"]];
            
            if (URL) {
                BOOL isDataScheme = [URL.scheme.lowercaseString isEqualToString:@"data"];
                
                if (URL.fileURL || isDataScheme) {
                    NSError *error;
                    NSData *data = [NSData dataWithContentsOfURL:URL
                                                         options:(NSDataReadingOptions)0
                                                           error:&error];
                    if (!data) {
                        failureCallback(error);
                        return;
                    }
                    
                    NSString *mime = @"application/octet-stream";
                    NSString *filename = @"file";
                    
                    if([options objectForKey:@"type"]){
                        mime = [RCTConvert NSString:options[@"type"]];
                    }
                    
                    if([options objectForKey:@"filename"]){
                        filename = [RCTConvert NSString:options[@"filename"]];
                        
                        
                        // add extension just like Android for consistency
                        // file name should not include extension
                        if(URL.isFileURL){
                            NSString *ext = [[URL.absoluteString componentsSeparatedByString:@"."] lastObject];
                            
                            filename = [filename stringByAppendingString: [@"." stringByAppendingString:ext]];
                        }
                        else if (isDataScheme){
                            NSString *ext = [Utils getExtensionFromBase64: URL.absoluteString];
                            
                            if(ext){
                                filename = [filename stringByAppendingString: [@"." stringByAppendingString:ext]];
                            }
                        }
                    }
                    else if(URL.fileURL){
                        NSArray *parts = [URL.absoluteString componentsSeparatedByString:@"/"];
                        filename = [parts lastObject];
                    }

                    // These checks basically make sure it's an MMS capable device with iOS7
                    if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
                    {
                      [mc addAttachmentData:data typeIdentifier:@"public.data" filename:@"image.png"];
                    }
                } else {
                    // if not a file, just append it to message
                    message = [message stringByAppendingString: [@" " stringByAppendingString: [RCTConvert NSString:options[@"url"]]] ];
                    [mc setBody:message];
                }
            }
                   
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *ctrl = RCTPresentedViewController();
          
            // Present mail view controller on screen
            [ctrl presentViewController:mc animated:YES completion:NULL];
            
            // We could fire this either here or
            // on the finish delegate.
            // For now, call it here for consistency with
            // GenericShare.shareSingle
            successCallback(@[]);
        });
    }
}

- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result error:(nullable NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *ctrl = RCTPresentedViewController();
        [ctrl dismissViewControllerAnimated:YES completion:NULL];
    });
}

@end

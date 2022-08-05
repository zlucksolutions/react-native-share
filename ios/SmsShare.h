//
//  SmsShare.h
//  RNShare
//
//  Created by Zluck Solutions on 04-08-22.
//  Copyright © 2016 Facebook. All rights reserved.
//


#import <UIKit/UIKit.h>
// import RCTConvertttt
#import <React/RCTConvert.h>
// import RCTBridge
#import <React/RCTBridge.h>
// import RCTUIManager
#import <React/RCTUIManager.h>
// import RCTLog
#import <React/RCTLog.h>
// import RCTUtils
#import <React/RCTUtils.h>
#import <MessageUI/MessageUI.h>
@interface SmsShare : NSObject <MFMessageComposeViewControllerDelegate>

- (void) shareSingle:(NSDictionary *)options failureCallback:(RCTResponseErrorBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback;
@end
